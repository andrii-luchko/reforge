import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';

// Repository abstraction is intentionally retained for DI and test doubles.
// ignore: one_member_abstracts
abstract interface class WorkoutProgramRepository {
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day);
}
