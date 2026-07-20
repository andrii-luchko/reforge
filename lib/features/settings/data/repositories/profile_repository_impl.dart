import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/settings/data/request/profile_requests.dart';
import 'package:reforge/features/settings/domain/repositories/profile_repository.dart';

@LazySingleton(as: ProfileRepository)
class ProfileRepositoryImpl with RepositoryErrorHandler implements ProfileRepository {
  ProfileRepositoryImpl(
    this._apiClient,
  );

  final ApiClient _apiClient;

  @override
  Future<Result<String>> updateUsername(String username) async {
    try {
      final response = await makeRequest(
        () => _apiClient.updateUsername(username),
        label: 'updateUsername',
      );
      return Result.success(response.data.username);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateAvatar(String avatarUrl) async {
    try {
      final response = await makeRequest(
        () => _apiClient.updateAvatar(avatarUrl),
        label: 'updateAvatar',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateFactions({int? mainFaction, int? secondFaction}) async {
    try {
      final request = UpdateFactionsRequest(
        mainFaction: mainFaction,
        secondFaction: secondFaction,
      );
      final response = await makeRequest(
        () => _apiClient.updateFactions(request),
        label: 'updateFactions',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateBirthDate(DateTime birthDate) async {
    try {
      final birthDateStr =
          "${birthDate.year.toString().padLeft(4, '0')}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}";
      final response = await makeRequest(
        () => _apiClient.updateBirthDate(birthDateStr),
        label: 'updateBirthDate',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateMeasurementSystem(MeasurementSystem measurementSystem) async {
    try {
      final request = UpdateMeasurementSystemRequest(
        measurementSystem: measurementSystem,
      );

      final response = await makeRequest(
        () => _apiClient.updateMeasurementSystem(request),
        label: 'updateMeasurementSystem',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateWorkoutDays({int? workoutsPerWeek, List<int>? specificDays}) async {
    try {
      final request = UpdateWorkoutDaysRequest(
        workoutDaysPerWeek: workoutsPerWeek,
        specificWorkoutDays: specificDays,
      );
      final response = await makeRequest(
        () => _apiClient.updateWorkoutDays(request),
        label: 'updateWorkoutDays',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateBodyWeight(int bodyWeight) async {
    try {
      final response = await makeRequest(
        () => _apiClient.updateBodyWeight(bodyWeight),
        label: 'updateBodyWeight',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<User>> updateNotificationSettings({bool? remindersEnabled, bool? announcementsEnabled}) async {
    try {
      final request = UpdateNotificationsRequest(
        remindersEnabled: remindersEnabled,
        announcementsEnabled: announcementsEnabled,
      );
      final response = await makeRequest(
        () => _apiClient.updateNotificationSettings(request),
        label: 'updateNotificationSettings',
      );
      final user = response.data;

      return Result.success(user);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
