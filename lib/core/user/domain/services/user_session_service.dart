import 'package:reforge/core/auth/data/models/user.dart';

abstract interface class UserSessionService {
  int? get currentUserId;
  User? get currentUser;

  Future<void> saveUser(User user);

  Future<void> clearUser();
}
