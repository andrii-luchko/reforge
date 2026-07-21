// ignore_for_file: no_empty_block
import 'dart:async';
import 'dart:io';
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
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/domain/repositories/profile_repository.dart';

part 'user_cubit.freezed.dart';
part 'user_state.dart';

@singleton
class UserCubit extends Cubit<UserState> {
  UserCubit(
    this._authCubit,
    this._userRepository,
    this._profileRepository,
    this._userSessionService,
    this._analytics,
  ) : super(const UserState.loading()) {
    // Subscribe to authentication state changes
    _authSubscription = _authCubit.stream.listen(_onAuthStateChanged);
  }

  final AuthCubit _authCubit;
  final UserRepository _userRepository;
  final ProfileRepository _profileRepository;
  final UserSessionService _userSessionService;
  final AnalyticsService _analytics;
  StreamSubscription<AuthState>? _authSubscription;

  OnboardedUser? get currentOnboardedUser => switch (state.userOrNull) {
    final OnboardedUser user => user,
    _ => null,
  };

  Stream<OnboardedUser?> get onboardedUserChanges => stream
      .where((state) => state is Loaded || state is Initial || state is Deleted)
      .map(
        (state) => switch (state) {
          Loaded(:final user) when user is OnboardedUser => user,
          _ => null,
        },
      )
      .distinct();

  Future<void> _onAuthStateChanged(AuthState state) async {
    await state.when(
      authenticated: (_) => _loadUserProfile(),
      unauthenticated: () {
        unawaited(_analytics.setUserId(null));
        unawaited(_userSessionService.clearUser());
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
    emit(const UserState.loading());

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
      case Failure(:final error):
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
        await _userSessionService.saveUser(user);
        emit(UserState.loaded(user));
      case Failure(:final error):
        emit(UserState.error(error.toString()));
        emit(currentState);
    }
  }

  Future<void> deleteUser() async {
    if (state case final Loaded currentState) {
      final user = currentState.user;

      emit(UserState.updating(user));
      final result = await _userRepository.deleteUser();

      switch (result) {
        case Success():
          emit(const UserState.deleted());
          await _userSessionService.clearUser();
        case Failure(:final error):
          emit(UserState.error(error.toString()));
          emit(UserState.loaded(user));
      }
    }
  }

  Future<void> deleteUserById() async {
    if (state case final Loaded currentState) {
      final user = currentState.user;

      emit(UserState.updating(user));
      final result = await _userRepository.deleteUserById(user.id);

      switch (result) {
        case Success():
          emit(const UserState.deleted());
          await _userSessionService.clearUser();
        case Failure(:final error):
          emit(UserState.error(error.toString()));
          emit(UserState.loaded(user));
      }
    }
  }

  Future<Result<User>> updateUsername(String username) async {
    if (state case Loaded(user: final OnboardedUser oldUser)) {
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateUsername(username);
      switch (result) {
        case Success(value: final updatedUsername):
          return _updateUser(
            Result.success(oldUser.copyWith(userName: updatedUsername)),
            oldUser,
          );
        case Failure(:final error):
          emit(UserState.loaded(oldUser));
          return Result.error(error);
      }
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateAvatarURL(String avatarUrl) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateAvatar(avatarUrl);
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateFactions({int? mainFaction, int? secondFaction}) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateFactions(
        mainFaction: mainFaction,
        secondFaction: secondFaction,
      );
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateBirthDate(DateTime birthDate) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateBirthDate(birthDate);
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateMeasurementSystem(MeasurementSystem measurementSystem) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateMeasurementSystem(measurementSystem);
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateWorkoutDays({int? workoutsPerWeek, List<int>? specificDays}) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateWorkoutDays(
        workoutsPerWeek: workoutsPerWeek,
        specificDays: specificDays,
      );
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateBodyWeight(double bodyWeight) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateBodyWeight(bodyWeight);
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> updateNotificationSettings({bool? remindersEnabled, bool? announcementsEnabled}) async {
    if (state case final Loaded currentState) {
      final oldUser = currentState.user;
      emit(UserState.updating(oldUser));
      final result = await _profileRepository.updateNotificationSettings(
        remindersEnabled: remindersEnabled,
        announcementsEnabled: announcementsEnabled,
      );
      return _updateUser(result, oldUser);
    }
    return Result.error(Exception('User not loaded'));
  }

  Future<Result<User>> _updateUser(Result<User> result, User oldUser) async {
    switch (result) {
      case Success(value: final updatedUser):
        final normalizedUser = updatedUser.copyWith(email: updatedUser.email ?? oldUser.email);
        await _userSessionService.saveUser(normalizedUser);
        if (normalizedUser case final OnboardedUser onboarded) {
          unawaited(_setUserAnalyticsProperties(onboarded));
        }
        emit(UserState.loaded(normalizedUser));
        return Result.success(normalizedUser);

      case Failure(:final error):
        emit(UserState.loaded(oldUser));
        return Result.error(error);
    }
  }

  Future<Result<User>> uploadUserAvatar(File file) async {
    final result = await _userRepository.uploadUserAvatar(file);

    switch (result) {
      case Success(value: final url):
        logger.d(result);
        return updateAvatarURL(url);
      case Failure(:final error):
        return Result.error(error);
    }
  }

  Future<Result<User>> deleteUserAvatar() => updateAvatarURL('undefined/bench-1rm-1.png');

  Future<Result<User>> updateEmail(String newEmail) async {
    final currentState = state;
    if (currentState is! Loaded) return Result.error(Exception('User not loaded'));
    final normalizedEmail = newEmail.trim();
    if (normalizedEmail == currentState.user.email) {
      return Result.success(currentState.user);
    }

    emit(UserState.updating(currentState.user));
    final result = await _userRepository.updateUserEmail(
      email: normalizedEmail,
      userId: currentState.user.id,
    );

    switch (result) {
      case Success(value: final updatedEmail):
        final updatedUser = currentState.user.copyWith(email: updatedEmail);
        return _updateUser(Result.success(updatedUser), currentState.user);

      case Failure(:final error):
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
