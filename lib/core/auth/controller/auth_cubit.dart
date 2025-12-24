import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/auth/domain/repositories/auth_repository.dart';
import 'package:reforge/core/auth/services/session_service.dart';

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository,
    this._localDataSource,
    this._sessionService,
  ) : super(const AuthState.loading()) {
    unawaited(_initialize());
  }

  final AuthRepository _authRepository;
  final AuthLocalDataSource _localDataSource;
  final SessionService _sessionService;

  Future<void> _initialize() async {
    final tokens = await _localDataSource.getTokens();
    if (tokens != null) {
      // Try to get current user to verify session
      final userResult = await _authRepository.getCurrentUser();
      switch (userResult) {
        case Success(value: final user):
          _sessionService.setSession(user, tokens);
          emit(AuthState.authenticated(user: user, tokens: tokens));
        case Error():
          // Token might be invalid, clear and go to unauthenticated
          await _localDataSource.clearTokens();
          _sessionService.clearSession();
          emit(const AuthState.unauthenticated());
      }

      logger.d('Tokens found during initialization: $tokens');
      // Check if tokens are still valid
      // if (tokens.expiresAt.isAfter(DateTime.now())) {
      //   // Try to get current user to verify session
      //   final userResult = await _authRepository.getCurrentUser();
      //   switch (userResult) {
      //     case Success(value: final user):
      //       _sessionService.setSession(user, tokens);
      //       emit(AuthState.authenticated(user: user, tokens: tokens));
      //     case Error():
      //       // Token might be invalid, clear and go to unauthenticated
      //       await _localDataSource.clearTokens();
      //       _sessionService.clearSession();
      //       emit(const AuthState.unauthenticated());
      //   }
      // } else {
      // // Token expired, try to refresh
      // final refreshResult = await _authRepository.refreshToken(tokens.refreshToken);
      // switch (refreshResult) {
      //   case Success(value: final newTokens):
      //     await _localDataSource.saveTokens(newTokens);
      //     final userResult = await _authRepository.getCurrentUser();
      //     switch (userResult) {
      //       case Success(value: final user):
      //         _sessionService.setSession(user, newTokens);
      //         emit(AuthState.authenticated(user: user, tokens: newTokens));
      //       case Error():
      //         await _localDataSource.clearTokens();
      //         _sessionService.clearSession();
      //         emit(const AuthState.unauthenticated());
      //     }
      //   case Error():
      //     // Refresh failed, clear and go to unauthenticated
      //     await _localDataSource.clearTokens();
      //     _sessionService.clearSession();
      //     emit(const AuthState.unauthenticated());
      // }
      //}
    } else {
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signin(email, password);

    switch (result) {
      case Success(value: final tokens):
        await _localDataSource.saveTokens(tokens);

        // Get current user after successful sign in
        final userResult = await _authRepository.getCurrentUser();
        switch (userResult) {
          case Success(value: final user):
            _sessionService.setSession(user, tokens);
            emit(AuthState.authenticated(user: user, tokens: tokens));
          case Error(error: final error):
            logger.e('Failed to get current user after sign in: $error');
            // Even if getCurrentUser fails, we have tokens, so we're authenticated
            // But we should handle this better - maybe store a minimal user or retry
            emit(AuthState.authenticated(tokens: tokens));
        }
      case Error(error: final error):
        emit(AuthState.error('Sign in failed: $error'));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signup(email, password);

    await Future.delayed(const Duration(seconds: 2));

    switch (result) {
      case Success(value: final tokens):
        await _localDataSource.saveTokens(tokens);

        emit(AuthState.authenticated(tokens: tokens));

      case Error(error: final error):
        emit(AuthState.error('Sign up failed: $error'));
    }
  }

  Future<void> signOut() async {
    await _localDataSource.clearTokens();
    _sessionService.clearSession();
    emit(const AuthState.unauthenticated());
  }
}
