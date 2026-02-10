import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/data/requests/update_profile_request.dart';
import 'package:reforge/features/settings/data/request/patch_profile_request.dart';

/// Repository interface for user-related operations
abstract interface class UserRepository {
  /// Get the current authenticated user
  Future<Result<User?>> getCurrentUser();

  /// Update user profile
  /// Takes a full UpdateProfileRequest with all required fields
  Future<Result<User>> updateProfile(UpdateProfileRequest request);

  /// Update user profile by a patch
  /// Takes parts of UpdateProfileRequest with fields
  Future<Result<User>> updateUser(PatchProfileRequest request);

  /// Delete the current user
  Future<Result<void>> deleteUser();

  /// Delete user by ID (admin operation)
  Future<Result<void>> deleteUserById(int id);

  /// Refresh user data from server
  Future<Result<User>> refreshUser();
}
