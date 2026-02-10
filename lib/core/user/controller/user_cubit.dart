// ignore_for_file: no_empty_block
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
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
  ) : super(const UserState.loading()) {
    // Subscribe to authentication state changes
    _authSubscription = _authCubit.stream.listen(_onAuthStateChanged);
  }

  final AuthCubit _authCubit;
  final UserRepository _userRepository;
  final UserSessionService _userSessionService;
  StreamSubscription<AuthState>? _authSubscription;

  Future<void> _onAuthStateChanged(AuthState state) async {
    await state.when(
      authenticated: (_) => _loadUserProfile(),
      unauthenticated: () {
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

  /// Refresh user data from server
  Future<void> refreshUser() async {
    final result = await _userRepository.refreshUser();

    switch (result) {
      case Success(value: final user):
        emit(UserState.loaded(user));
      case ErrorR(error: final error):
        emit(UserState.error(error.toString()));
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

      emit(UserState.updating(oldUser));

      final result = await _userRepository.updateUser(request);

      switch (result) {
        case Success(value: final updatedUser):
          await _userSessionService.saveUser(updatedUser);
          emit(UserState.loaded(updatedUser));
          return result;

        case ErrorR(error: final error):
          emit(UserState.error(error.toString()));

          emit(UserState.loaded(oldUser));
          return result;
      }
    }
    return Result.error(Exception('User not loaded'));
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription?.cancel());
    return super.close();
  }
}
