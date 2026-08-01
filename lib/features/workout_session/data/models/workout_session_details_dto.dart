import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';
import 'package:reforge/features/exercise_session/data/models/workout_exercise_session_dto.dart';
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
    @JsonKey(name: 'exerciseSessions') List<WorkoutExerciseSessionDTO>? exerciseSessions,
    @JsonKey(name: 'workoutSessions') List<WorkoutExerciseSessionDTO>? workoutSessions,
    @JsonKey(name: 'createdAt') DateTime? createdAt,
  }) = _WorkoutSessionDetailsDTO;

  factory WorkoutSessionDetailsDTO.fromJson(Map<String, dynamic> json) => _$WorkoutSessionDetailsDTOFromJson(json);
}

extension WorkoutSessionDetailsDTOX on WorkoutSessionDetailsDTO {
  /// Exercise sessions returned by the current backend contract.
  ///
  /// `workoutSessions` contains the same data in older responses and remains
  /// a fallback only. Mixing both arrays would turn the mirrored payload into
  /// artificial duplicates.
  List<WorkoutExerciseSessionDTO> get normalizedExerciseSessions {
    final primary = exerciseSessions;
    if (primary != null && primary.isNotEmpty) return primary;
    return workoutSessions ?? const <WorkoutExerciseSessionDTO>[];
  }

  /// Selects one session per program exercise.
  ///
  /// Duplicate sessions are legacy/test data. Prefer the first session with
  /// recorded sets; otherwise preserve the first item returned by the server.
  ///
  /// After a swap the backend can store completed sets in a separate active
  /// session without `workoutProgramExerciseId`. Such a session is merged into
  /// its unique swapped parent by exercise id while the parent session id is
  /// preserved for subsequent swap operations.
  Map<int, WorkoutExerciseSessionDTO> get exerciseSessionsByProgramExerciseId {
    final selected = <int, WorkoutExerciseSessionDTO>{};
    final unbound = <WorkoutExerciseSessionDTO>[];
    for (final session in normalizedExerciseSessions) {
      final programExerciseId = session.workoutProgramExerciseId;
      if (programExerciseId == null) {
        unbound.add(session);
        continue;
      }
      final existing = selected[programExerciseId];
      if (existing == null || (existing.sets.isEmpty && session.sets.isNotEmpty)) {
        selected[programExerciseId] = session;
      }
    }

    for (final child in unbound) {
      final matchingParents = selected.entries
          .where(
            (entry) => entry.value.isSwapped && entry.value.swappedExerciseId == child.exerciseId,
          )
          .toList();
      if (matchingParents.length != 1) continue;

      final parent = matchingParents.single;
      selected[parent.key] = _mergeUnboundSession(parent.value, child);
    }
    return Map.unmodifiable(selected);
  }

  int get unboundExerciseSessionCount =>
      normalizedExerciseSessions.where((session) => session.workoutProgramExerciseId == null).length;

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
    final sessions = exerciseSessionsByProgramExerciseId.values;

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
            sets: s.sets.map((e) => e.toWorkoutSet(system)).toList(),
          ),
        )
        .toList();
  }

  WorkoutExerciseSessionDTO _mergeUnboundSession(
    WorkoutExerciseSessionDTO parent,
    WorkoutExerciseSessionDTO child,
  ) {
    final setsById = {
      for (final set in parent.sets) set.id: set,
      for (final set in child.sets) set.id: set,
    };
    final parentNotes = parent.notes;
    return parent.copyWith(
      sets: setsById.values.toList(),
      notes: parentNotes == null || parentNotes.isEmpty ? child.notes : parentNotes,
      lastCompletedSet: parent.lastCompletedSet ?? child.lastCompletedSet,
      updatedAt: _latest(parent.updatedAt, child.updatedAt),
    );
  }

  DateTime? _latest(DateTime? first, DateTime? second) {
    if (first == null) return second;
    if (second == null) return first;
    return first.isAfter(second) ? first : second;
  }
}
