// ignore_for_file: no_empty_block
import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/analytics/domain/analytics_user_properties.dart';
import 'package:reforge/core/analytics/domain/helpers/anonymization_helpers.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/domain/repositories/user_repository.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';

part 'user_cubit.freezed.dart';
part 'user_state.dart';

@singleton
class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._authCubit,
    this._userRepository,
    this._userSessionService,
    this._analytics,
  ) : super(const UserState.loading()) {
    // Subscribe to authentication state changes
    _authSubscription = _authCubit.stream.listen(_onAuthStateChanged);
  }

  final AuthCubit _authCubit;
  final UserRepository _userRepository;
  final UserSessionService _userSessionService;
  final AnalyticsService _analytics;
  StreamSubscription<AuthState>? _authSubscription;

  Future<void> _onAuthStateChanged(AuthState state) async {
    await state.when(
      authenticated: (_) => _loadUserProfile(),
      unauthenticated: () {
        unawaited(_analytics.setUserId(null));
        // Clear user data on logout
        emit(const UserState.initial());
      },
      error: (message) {
        // Handle auth errors if needed
      },
      loading: () {},
    );
  }

  Future<void> _loadUserProfile() async {
    final cachedUser = _userSessionService.currentUser;

    if (cachedUser != null) {
      emit(UserState.loaded(cachedUser));
    } else {
      emit(const UserState.loading());
    }

    final result = await _userRepository.getCurrentUser();

    switch (result) {
      case Success(value: final user):
        if (user != null) {
          await _userSessionService.saveUser(user);
          unawaited(_analytics.setUserId('${user.id}'));
          if (user case final OnboardedUser onboarded) {
            unawaited(_setUserAnalyticsProperties(onboarded));
          }
          emit(UserState.loaded(user));
        } else {
          await _userSessionService.clearUser();
          emit(const UserState.initial());
        }
      case ErrorR(error: final error):
        await _userSessionService.clearUser();
        emit(UserState.error(error.toString()));
    }
  }

  Future<void> _setUserAnalyticsProperties(OnboardedUser user) async {
    await _analytics.setUserProperty(
      AnalyticsUserProperties.measurementSystem,
      user.measurementSystem.name,
    );
    await _analytics.setUserProperty(
      AnalyticsUserProperties.factionId,
      '${user.factionId}',
    );
    await _analytics.setUserProperty(
      AnalyticsUserProperties.workoutsPerWeek,
      '${user.workoutsPerWeek}',
    );
    await _analytics.setUserProperty(
      AnalyticsUserProperties.ageGroup,
      AnonymizationHelpers.ageGroup(user.birthDate),
    );
    await _analytics.setUserProperty(
      AnalyticsUserProperties.weightRange,
      AnonymizationHelpers.weightBucket(user.bodyWeight),
    );
  }

  /// Refresh user data from server
  Future<void> refreshUser() async {
    final currentState = state;
    final result = await _userRepository.refreshUser();

    switch (result) {
      case Success(value: final user):
        emit(UserState.loaded(user));
      case ErrorR(error: final error):
        emit(UserState.error(error.toString()));
        emit(currentState);
    }
  }

  Future<void> deleteUser() async {
    final currentState = state;
    if (currentState is! Loaded) return;
    emit(const UserState.loading());
    final result = await _userRepository.deleteUser();

    switch (result) {
      case Success():
        emit(const UserState.deleted());
      case ErrorR(error: final error):
        emit(UserState.error(error.toString()));
        emit(currentState);
    }
  }

  Future<void> deleteUserById() async {
    final currentState = state;
    if (currentState is! Loaded) return;
    emit(const UserState.loading());
    final result = await _userRepository.deleteUserById(currentState.user.id);

    switch (result) {
      case Success():
        emit(const UserState.deleted());
      case ErrorR(error: final error):
        emit(UserState.error(error.toString()));
        emit(currentState);
    }
  }

  Future<Result<User>> updateProfile(PatchProfileRequest request) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;

      if (_isSameData(oldUser, request)) {
        return Result.success(oldUser);
      }
      emit(UserState.updating(oldUser));

      final result = await _userRepository.updateUser(request);

      switch (result) {
        case Success(value: final updatedUser):
          await _userSessionService.saveUser(updatedUser);
          if (updatedUser case final OnboardedUser onboarded) {
            unawaited(_setUserAnalyticsProperties(onboarded));
          }
          emit(UserState.loaded(updatedUser.copyWith(email: oldUser.email)));
          return result;

        case ErrorR(error: final error):
          emit(UserState.error(error.toString()));

          emit(UserState.loaded(oldUser));
          return result;
      }
    }
    return Result.error(Exception('User not loaded'));
  }

  bool _isSameData(User user, PatchProfileRequest request) {
    if (user is! OnboardedUser) return false;

    if (request.username != null && user.userName != request.username) return false;
    if (request.avatarUrl != null && user.avatarUrl != request.avatarUrl) return false;
    if (request.mainFaction != null && user.factionId != request.mainFaction) return false;
    if (request.secondFaction != null && user.secondaryFactionId != request.secondFaction) return false;
    if (request.dateOfBirth != null && !DateUtils.isSameDay(user.birthDate, request.dateOfBirth)) return false;
    if (request.measurementSystem != null && user.measurementSystem != request.measurementSystem) return false;
    if (request.workoutDaysPerWeek != null && user.workoutsPerWeek != request.workoutDaysPerWeek) return false;

    if (request.specificWorkoutDays != null) {
      const listEquals = ListEquality();
      if (!listEquals.equals(user.specificDays, request.specificWorkoutDays)) return false;
    }

    if (request.bodyWeight != null && user.bodyWeight?.round() != request.bodyWeight) return false;
    if (request.remindersEnabled != null && user.remindersEnabled != request.remindersEnabled) return false;
    if (request.announcementsEnabled != null && user.announcementsEnabled != request.announcementsEnabled) return false;

    return true;
  }

  Future<void> uploadUserAvatar(File file) async {
    final currentState = state;

    final result = await _userRepository.uploadUserAvatar(file);

    switch (result) {
      case Success(value: final url):
        logger.d(result);
        await updateProfile(PatchProfileRequest(avatarUrl: url));
      case ErrorR(error: final error):
        emit(UserState.error(error.toString()));
        emit(currentState);
    }
  }

  Future<Result<User>> updateEmail(String newEmail) async {
    final currentState = state;
    if (currentState is! Loaded) return Result.error(Exception('User not loaded'));
    final result = await _userRepository.updateUserEmail(
      email: newEmail,
      userId: currentState.user.id,
    );

    switch (result) {
      case Success():
        await _userSessionService.saveUser(currentState.user.copyWith(email: newEmail));
        emit(UserState.loaded(currentState.user.copyWith(email: newEmail)));

        return Result.success(currentState.user.copyWith(email: newEmail));

      case ErrorR(error: final error):
        emit(UserState.loaded(currentState.user));
        return Result.error(error);
    }
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription?.cancel());
    return super.close();
  }
}
