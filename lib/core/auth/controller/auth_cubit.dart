import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/repositories/auth_repository.dart';
import 'package:reforge/core/auth/domain/repositories/auth_repository.dart' as domain;

part 'auth_cubit.freezed.dart';
part 'auth_state.dart';

@singleton
class AuthCubit extends Cubit<AuthState> {
  AuthCubit(
    this._authRepository,
    this._analytics,
  ) : super(const AuthState.loading()) {
    unawaited(_initialize());
  }

  final domain.AuthRepository _authRepository;
  final AnalyticsService _analytics;

  Future<void> _initialize() async {
    final result = await _authRepository.getTokens();
    switch (result) {
      case Success(value: final tokens):
        if (tokens != null) {
          emit(AuthState.authenticated(tokens: tokens));
          logger.d('Tokens found during initialization: $tokens');
        } else {
          emit(const AuthState.unauthenticated());
        }
      case ErrorR(error: final error):
        emit(AuthState.error('get tokens failed: $error'));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signin(email, password);

    switch (result) {
      case Success(value: final tokens):
        unawaited(_analytics.logLogin(method: 'email'));
        emit(AuthState.authenticated(tokens: tokens));
      case ErrorR(error: final error):
        emit(AuthState.error('Sign in failed: $error'));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(const AuthState.loading());

    final result = await _authRepository.signup(email, password);

    switch (result) {
      case Success(value: final tokens):
        unawaited(_analytics.logSignUp(method: 'email'));
        emit(AuthState.authenticated(tokens: tokens));
      case ErrorR(error: final error):
        emit(AuthState.error('Sign up failed: $error'));
    }
  }

  Future<void> signWithGoogle() async {
    emit(const AuthState.loading());

    final result = await _authRepository.signWithGoogle();

    switch (result) {
      case Success(value: final tokens):
        unawaited(_analytics.logLogin(method: 'google'));
        emit(AuthState.authenticated(tokens: tokens));
      case ErrorR(error: final error):
        if (error is AuthCanceledException) {
          emit(const AuthState.unauthenticated());
        } else {
          logger.d(error);
          emit(AuthState.error('Sign up failed: $error'));
        }
    }
  }

  Future<void> signWithApple() async {
    emit(const AuthState.loading());

    final result = await _authRepository.signWithApple();

    switch (result) {
      case Success(value: final tokens):
        unawaited(_analytics.logLogin(method: 'apple'));
        emit(AuthState.authenticated(tokens: tokens));
      case ErrorR(error: final error):
        if (error is AuthCanceledException) {
          emit(const AuthState.unauthenticated());
        } else {
          emit(AuthState.error('Sign up failed: $error'));
        }
    }
  }

  Future<void> signOut() async {
    final currentState = state;

    if (state is! _Authenticated) return;
    emit(const AuthState.loading());

    final result = await _authRepository.signOut();

    switch (result) {
      case Success():
        unawaited(_analytics.setUserId(null));
        emit(const AuthState.unauthenticated());
      case ErrorR(error: final error):
        emit(AuthState.error('Sign up failed: $error'));
        emit(currentState);
    }
  }
}
