import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/core/user/data/datasources/user_local_datasource.dart';
import 'package:reforge/core/user/data/datasources/user_remote_datasource.dart';
import 'package:reforge/core/user/domain/repositories/user_repository.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart' as requests;

@Injectable(as: UserRepository)
class UserRepositoryImpl with RepositoryErrorHandler implements UserRepository {
  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
  );

  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await makeRequest(
        _remoteDataSource.getCurrentUser,
        label: 'getCurrentUser',
      );
      await _localDataSource.saveUser(user);

      logger.d(user);

      return Result.success(user);
    } on Exception catch (e) {
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
      final updatedUser = await makeRequest(
        () => _remoteDataSource.updateProfile(request),
        label: 'updateProfile',
      );
      await _localDataSource.saveUser(updatedUser);
      return Result.success(updatedUser);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteUser() async {
    try {
      await makeRequest(
        _remoteDataSource.deleteUser,
        label: 'deleteUser',
      );
      await _localDataSource.clearUser();
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> deleteUserById(int id) async {
    try {
      await makeRequest(
        () => _remoteDataSource.deleteUserById(id),
        label: 'deleteUserById',
      );
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
      final user = await makeRequest(
        _remoteDataSource.getCurrentUser,
        label: 'refreshUser',
      );
      await _localDataSource.saveUser(user);
      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<String>> uploadUserAvatar(File file) async {
    try {
      final result = await makeRequest(
        () => _remoteDataSource.uploadUserAvatar(file),
        label: 'uploadUserAvatar',
      );
      return Result.success(result);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> updateUserEmail({required String email, required int userId}) async {
    try {
      await makeRequest(
        () => _remoteDataSource.updateUserEmail(email, userId),
        label: 'updateUserEmail',
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
