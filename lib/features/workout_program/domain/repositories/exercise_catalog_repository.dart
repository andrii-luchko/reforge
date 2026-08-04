// ignore_for_file: one_member_abstracts

import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';

abstract interface class ExerciseCatalogRepository {
  Future<Result<ExerciseDetailsEntity>> getExercise(int exerciseId);
}
