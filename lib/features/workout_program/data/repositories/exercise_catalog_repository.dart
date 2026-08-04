// ignore_for_file: prefer_match_file_name

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/exercise_catalog_repository.dart';

@LazySingleton(as: ExerciseCatalogRepository)
class ExerciseCatalogRepositoryImpl with RepositoryErrorHandler implements ExerciseCatalogRepository {
  ExerciseCatalogRepositoryImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<ExerciseDetailsEntity>> getExercise(int exerciseId) async {
    try {
      final response = await makeRequest(
        () => _apiClient.getExercise(exerciseId),
        label: 'getExercise',
      );
      return Result.success(response.data.toEntity());
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
