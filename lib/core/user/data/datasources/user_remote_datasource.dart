import 'dart:io';

import 'package:injectable/injectable.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';

abstract interface class UserRemoteDataSource {
  Future<User> getCurrentUser();
  Future<User> updateProfile(UpdateProfileRequest request);
  Future<User> patchUser(PatchProfileRequest request);
  Future<void> deleteUser();
  Future<void> deleteUserById(int id);
  Future<String> uploadUserAvatar(File file);
}

@Injectable(as: UserRemoteDataSource)
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<User> getCurrentUser() async {
    final response = await _apiClient.getCurrentUser();
    return response.data;
  }

  @override
  Future<User> updateProfile(UpdateProfileRequest request) async {
    await _apiClient.updateProfile(request);
    // After update, fetch the updated user
    return getCurrentUser();
  }

  @override
  Future<User> patchUser(PatchProfileRequest request) async {
    final response = await _apiClient.updateCurrentUser(request);

    return response.data;
  }

  @override
  Future<void> deleteUser() async {
    await _apiClient.deleteUser();
  }

  @override
  Future<void> deleteUserById(int id) async {
    await _apiClient.deleteUserById(id);
  }

  @override
  Future<String> uploadUserAvatar(File file) async {
    const bucketName = 'user_avatar_bucket';
    final response = await _apiClient.uploadFile(bucket: bucketName, file: file);
    return response.data;
  }
}
