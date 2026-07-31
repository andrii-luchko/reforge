import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/workout_program/data/models/program_day_dto.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/workout_program_repository.dart';

@Injectable(as: WorkoutProgramRepository)
class WorkoutProgramRepositoryImpl with RepositoryErrorHandler implements WorkoutProgramRepository {
  WorkoutProgramRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<ProgramDayEntity?>> getWorkoutByDay(int day) async {
    try {
      final response = await makeRequest(
        () => _apiClient.getWorkoutByDay(day),
        label: 'getWorkoutByDay',
      );
      return response.data.isEmpty ? const Result.success(null) : Result.success(response.data.first.toEntity());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
