import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';

@Singleton(as: UserSessionService)
class UserSessionServiceImpl implements UserSessionService {
  User? _currentUser;

  @override
  User? get currentUser => _currentUser;

  @override
  int? get currentUserId => _currentUser?.id;

  @override
  Future<void> saveUser(User user) async {
    _currentUser = user;
  }

  @override
  Future<void> clearUser() async {
    _currentUser = null;
  }
}
