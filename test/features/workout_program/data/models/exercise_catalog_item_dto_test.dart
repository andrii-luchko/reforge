import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/app/utils/helpers/base_response.dart';
import 'package:reforge/features/workout_program/data/models/exercise_catalog_item_dto.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  test('maps catalog Running details without program-only type or key', () {
    final response = BaseResponse<ExerciseCatalogItemDTO>.fromJson(
      jsonDecode(
            File(
              'test/features/workout_program/data/fixtures/running_exercise_catalog.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>,
      (json) => ExerciseCatalogItemDTO.fromJson(json! as Map<String, dynamic>),
    );

    final exercise = response.data.toEntity();
    expect(exercise.id, 4);
    expect(exercise.name, 'Running');
    expect(exercise.key, isNull);
    expect(exercise.type, isNull);
    expect(exercise.factionId, 3);
    expect(exercise.metrics, [WorkoutMetric.time, WorkoutMetric.distance]);
    expect(exercise.isRunningSwapCandidate, isTrue);
  });
}
