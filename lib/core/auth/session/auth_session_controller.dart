import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/datasources/auth_local_datasource.dart';

enum SessionEndReason { refreshTokenInvalid }

abstract interface class AuthSessionController {
  Stream<SessionEndReason> get invalidations;

  Future<void> invalidate(SessionEndReason reason);
}

@Singleton(as: AuthSessionController)
class AuthSessionControllerImpl implements AuthSessionController {
  AuthSessionControllerImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;
  final _invalidations = StreamController<SessionEndReason>.broadcast();
  Future<void>? _invalidation;

  @override
  Stream<SessionEndReason> get invalidations => _invalidations.stream;

  @override
  Future<void> invalidate(SessionEndReason reason) {
    return _invalidation ??= _invalidate(reason);
  }

  Future<void> _invalidate(SessionEndReason reason) async {
    try {
      await _localDataSource.clearTokens();
      _invalidations.add(reason);
    } finally {
      _invalidation = null;
    }
  }
}
