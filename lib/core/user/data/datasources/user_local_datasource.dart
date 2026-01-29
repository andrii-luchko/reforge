import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/user.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();
}

@Injectable(as: UserLocalDataSource)
class UserLocalDataSourceImpl implements UserLocalDataSource {
  User? _cachedUser;

  @override
  Future<void> saveUser(User user) async {
    _cachedUser = user;
  }

  @override
  Future<User?> getUser() async {
    return _cachedUser;
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
  }
}
