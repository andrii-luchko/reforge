import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/data/datasources/user_local_datasource.dart';
import 'package:reforge/core/user/data/datasources/user_remote_datasource.dart';
import 'package:reforge/core/user/domain/repositories/user_repository.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart' as requests;
import 'package:reforge/features/settings/data/request/patch_profile_request.dart' as requests;

@Injectable(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // Try to get from remote first
      final user = await _remoteDataSource.getCurrentUser();
      // Cache locally
      await _localDataSource.saveUser(user);
      return Result.success(user);
    } on Exception catch (e) {
      // If remote fails, try local cache
      final cachedUser = await _localDataSource.getUser();
      if (cachedUser != null) {
        return Result.success(cachedUser);
      }
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateProfile(requests.UpdateProfileRequest request) async {
    try {
      final updatedUser = await _remoteDataSource.updateProfile(request);
      // Update local cache
      await _localDataSource.saveUser(updatedUser);
      return Result.success(updatedUser);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateUser(requests.PatchProfileRequest request) async {
    try {
      final updatedUser = await _remoteDataSource.patchUser(request);
      await _localDataSource.saveUser(updatedUser);
      return Result.success(updatedUser);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteUser() async {
    try {
      await _remoteDataSource.deleteUser();
      await _localDataSource.clearUser();
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteUserById(int id) async {
    try {
      await _remoteDataSource.deleteUserById(id);
      // If deleting current user, clear local cache
      final currentUser = await _localDataSource.getUser();
      if (currentUser?.id == id) {
        await _localDataSource.clearUser();
      }
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> refreshUser() async {
    try {
      final user = await _remoteDataSource.getCurrentUser();
      await _localDataSource.saveUser(user);
      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
