import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/controller/auth_cubit.dart';
import 'package:reforge/features/notifications/data/repository/notification_repository.dart';
import 'package:reforge/features/notifications/domain/enum/notification_permission_status.dart';

part 'notification_permission_cubit.freezed.dart';
part 'notification_permission_state.dart';

@injectable
class NotificationPermissionCubit extends Cubit<NotificationPermissionState> {
  NotificationPermissionCubit(this._repository, this._authCubit)
      : super(const NotificationPermissionState.checking()) {
    unawaited(checkPermission());
    _authSubscription = _authCubit.stream.listen(_onAuthStateChanged);
  }

  final NotificationRepository _repository;
  final AuthCubit _authCubit;
  StreamSubscription<AuthState>? _authSubscription;

  void _onAuthStateChanged(AuthState state) {
    state.whenOrNull(
      unauthenticated: () => unawaited(_repository.clearSavedFcmToken()),
    );
  }

  Future<void> checkPermission() async {
    final result = await _repository.getNotificationPermissionStatus();

    if (isClosed) return;

    switch (result) {
      case Success(value: final status):
        if (status == NotificationPermissionStatus.authorized || status == NotificationPermissionStatus.provisional) {
          unawaited(_fetchAndEmitToken());
        } else if (status == NotificationPermissionStatus.notDetermined) {
          emit(const NotificationPermissionState.permissionNotDetermined());
        } else {
          emit(const NotificationPermissionState.permissionDenied());
        }
      case ErrorR():
        emit(const NotificationPermissionState.permissionDenied());
    }
  }

  Future<void> _fetchAndEmitToken() async {
    final tokenResult = await _repository.getFcmToken();
    if (isClosed) return;
    switch (tokenResult) {
      case Success(value: final token):
        if (token != null) {
          unawaited(saveToken(token));
        }
        emit(NotificationPermissionState.permissionGranted(token: token));
      case ErrorR():
        emit(const NotificationPermissionState.permissionGranted());
    }
  }

  Future<bool> requestPermission() async {
    final currentState = state;
    if (currentState case _PermissionGranted()) {
      emit(currentState.copyWith(isRequestingPermission: true));
    }

    final result = await _repository.requestNotificationPermission();

    if (isClosed) return false;

    switch (result) {
      case Success(value: final granted):
        if (granted) {
          await _fetchAndEmitToken();
          return true;
        }
        if (currentState case final _PermissionGranted s) {
          emit(s.copyWith(isRequestingPermission: false));
        }
        return false;
      case ErrorR():
        if (currentState case final _PermissionGranted s) {
          emit(s.copyWith(isRequestingPermission: false));
        }
        return false;
    }
  }

  Future<void> saveToken(String token) async {
    await _repository.saveFcmToken(token);
    if (isClosed) return;
    final currentState = state;
    if (currentState case _PermissionGranted()) {
      // Token already in state, saveToken is for backend - mock logs
      if (kDebugMode) {
        logger.d('FCM token saved (mock): $token');
      }
    }
  }

  @override
  Future<void> close() {
    unawaited(_authSubscription?.cancel());
    return super.close();
  }
}
