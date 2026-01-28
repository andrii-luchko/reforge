import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/user.dart';

abstract interface class UserLocalDataSource {
  Future<void> saveUser(User user);
  Future<User?> getUser();
  Future<void> clearUser();
}

@Injectable(as: UserLocalDataSource)
class UserLocalDataSourceImpl implements UserLocalDataSource {
  // TODO: Implement using shared_preferences or similar
  User? _cachedUser;

  @override
  Future<void> saveUser(User user) async {
    _cachedUser = user;
    // TODO: Persist to local storage
  }

  @override
  Future<User?> getUser() async {
    return _cachedUser;
    // TODO: Load from local storage
  }

  @override
  Future<void> clearUser() async {
    _cachedUser = null;
    // TODO: Clear from local storage
  }
}
