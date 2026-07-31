import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/data/mock/mocked_day.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';

class TestWorkoutProgramRepository implements WorkoutProgramRepository {
  const TestWorkoutProgramRepository();

  @override
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day) async {
    return Result.success(mockProgramDay);
  }
}
