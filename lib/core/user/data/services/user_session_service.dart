import 'dart:async';
import 'dart:convert';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

@Singleton(as: UserSessionService)
class UserSessionServiceImpl implements UserSessionService {
  UserSessionServiceImpl(this._prefs) {
    _init();
  }

  final SharedPreferences _prefs;
  static const _userKey = 'cached_user_profile';

  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  int? get currentUserId => _currentUser?.id;

  void _init() {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString != null) {
      try {
        final json = jsonDecode(jsonString);
        _currentUser = User.fromJson(json as Map<String, dynamic>);
        // ignore: avoid_catches_without_on_clauses
      } catch (e) {
        unawaited(_prefs.remove(_userKey));
      }
    }
  }

  @override
  Future<void> saveUser(User user) async {
    try {
      _currentUser = user;

      final jsonString = jsonEncode(user.toJson());
      await _prefs.setString(_userKey, jsonString);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      logger.e('🔴 Error saving user session', e, stackTrace);
    }
  }

  @override
  Future<void> clearUser() async {
    try {
      _currentUser = null;
      await _prefs.remove(_userKey);
      // ignore: avoid_catches_without_on_clauses
    } catch (e, stackTrace) {
      logger.e('🔴 Error clear user session', e, stackTrace);
    }
  }
}
