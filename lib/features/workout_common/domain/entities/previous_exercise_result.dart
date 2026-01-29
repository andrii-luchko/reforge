import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

part 'previous_exercise_result.freezed.dart';

@freezed
sealed class PreviousExerciseResult with _$PreviousExerciseResult {
  const factory PreviousExerciseResult({
    required String name,
    required String description,
    String? imageUrl,
    @Default([]) List<WorkoutMetric> metrics,
    String? notes,
    List<WorkoutSet>? sets,
  }) = _PreviousExerciseResult;
}
