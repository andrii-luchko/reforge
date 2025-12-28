import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/auth_tokens.dart';
import 'package:reforge/core/auth/data/models/user.dart';

@singleton
class SessionService {
  User? _currentUser;
  AuthTokens? _currentTokens;
  bool _isAuthenticated = false;

  User? get currentUser => _currentUser;
  AuthTokens? get currentTokens => _currentTokens;
  bool get isAuthenticated => _isAuthenticated;

  void setSession(User? user, AuthTokens tokens) {
    _currentUser = user;
    _currentTokens = tokens;
    _isAuthenticated = true;
  }

  void clearSession() {
    _currentUser = null;
    _currentTokens = null;
    _isAuthenticated = false;
  }

  set currentUser(User user) {
    _currentUser = user;
  }

  set currentTokens(AuthTokens tokens) {
    _currentTokens = tokens;
  }
}

