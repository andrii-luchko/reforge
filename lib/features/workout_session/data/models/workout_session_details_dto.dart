import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/exercise_session/data/models/exercise_session_dto.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/models/exercise_details_dto.dart';
import 'package:reforge/features/workout_session/data/enums/workout_session_status.dart';

part 'workout_session_details_dto.freezed.dart';
part 'workout_session_details_dto.g.dart';

@freezed
sealed class WorkoutSessionDetailsDTO with _$WorkoutSessionDetailsDTO {
  const factory WorkoutSessionDetailsDTO({
    required int id,
    required int workoutProgramDayId,
    required int duration,
    required WorkoutSessionStatus status,
    required int totalXpEarned,
    // @JsonKey(name: 'exerciseSessions') List<ExerciseSessionDTO>? exerciseSessions, -- same as workoutSessions
    @JsonKey(name: 'workoutSessions') List<ExerciseSessionDTO>? workoutSessions,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _WorkoutSessionDetailsDTO;

  factory WorkoutSessionDetailsDTO.fromJson(Map<String, dynamic> json) => _$WorkoutSessionDetailsDTOFromJson(json);
}

extension WorkoutSessionDetailsDTOX on WorkoutSessionDetailsDTO {
  TrainingDetailsEntity toEntity(MeasurementSystem system) {
    return TrainingDetailsEntity(
      id: id,
      date: createdAt ?? DateTime.now(),
      duration: duration,
      totalXpEarned: totalXpEarned,
      exercises: toPreviousResults(system),
      measurementSystem: system,
    );
  }

  List<PreviousExerciseResult> toPreviousResults(MeasurementSystem system) {
    final sessions = workoutSessions ?? [];

    if (sessions.isEmpty) return [];

    return sessions
        .where((s) => s.exercise != null)
        .map(
          (s) => PreviousExerciseResult(
            name: s.exercise!.name,
            description: s.exercise!.description,
            imageUrl: s.exercise!.thumbnailInstructionUrl,
            metrics: s.exercise!.toEntity().metrics,
            notes: s.notes,
            sets: (s.sets ?? []).map((e) => e.toWorkoutSet(system)).toList(),
          ),
        )
        .toList();
  }
}
