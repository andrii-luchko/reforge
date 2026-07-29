import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

abstract interface class ProfileRepository {
  Future<Result<String>> updateUsername(String username);
  Future<Result<User>> updateAvatar(String avatarUrl);
  Future<Result<User>> updateFactions({int? mainFaction, int? secondFaction});
  Future<Result<User>> updateBirthDate(DateTime birthDate);
  Future<Result<User>> updateMeasurementSystem(MeasurementSystem measurementSystem);
  Future<Result<User>> updateWorkoutDays({int? workoutsPerWeek, List<int>? specificDays});
  Future<Result<User>> updateBodyWeight(double bodyWeight);
  Future<Result<User>> updateNotificationSettings({bool? remindersEnabled, bool? announcementsEnabled});
}
