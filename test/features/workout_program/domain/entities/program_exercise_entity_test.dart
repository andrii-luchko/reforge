import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/enums/exercise_type.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  group('ProgramExerciseEntity.isRunningExercise', () {
    test('returns true when the exercise has segments', () {
      final exercise = _programExercise(
        segments: [
          ExerciseSegmentEntity(
            id: 1,
            order: 1,
            activity: SegmentActivity.run,
            targetMetric: WorkoutMetric.distance,
            distanceM: 1000,
            durationSec: 0,
          ),
        ],
      );

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true for distance with time', () {
      final exercise = _programExercise(metrics: [WorkoutMetric.distance, WorkoutMetric.time]);

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true for distance with pace', () {
      final exercise = _programExercise(metrics: [WorkoutMetric.distance, WorkoutMetric.pace]);

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true for a time-only endurance exercise', () {
      final exercise = _programExercise(metrics: [WorkoutMetric.time], type: ExerciseType.endurance);

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true for a distance target with a time result', () {
      final exercise = _programExercise(
        metrics: [WorkoutMetric.time],
        runningTarget: const ExerciseRunningTarget.distance(3000),
      );

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true for a time target with a distance result', () {
      final exercise = _programExercise(
        metrics: [WorkoutMetric.distance],
        runningTarget: const ExerciseRunningTarget.duration(720),
      );

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns true when the key contains run regardless of case', () {
      final exercise = _programExercise(key: 'OutdoorRunning');

      expect(exercise.isRunningExercise, isTrue);
    });

    test('returns false for a time-only non-endurance exercise', () {
      final exercise = _programExercise(metrics: [WorkoutMetric.time], type: ExerciseType.strength);

      expect(exercise.isRunningExercise, isFalse);
    });

    test('returns false when none of the running signals are present', () {
      final exercise = _programExercise(metrics: [WorkoutMetric.reps], type: ExerciseType.endurance);

      expect(exercise.isRunningExercise, isFalse);
    });
  });
}

ProgramExerciseEntity _programExercise({
  List<WorkoutMetric> metrics = const [],
  ExerciseType? type,
  String key = 'exercise',
  ExerciseRunningTarget? runningTarget,
  List<ExerciseSegmentEntity> segments = const [],
}) {
  return ProgramExerciseEntity(
    id: 1,
    programDayId: 1,
    sets: 1,
    order: 1,
    executionMode: ExecutionMode.standard,
    exerciseDetails: ExerciseDetailsEntity(
      id: 1,
      name: 'Exercise',
      description: '',
      key: key,
      metrics: metrics,
      poseDetectionPreset: null,
      runningTarget: runningTarget,
      isTiered: false,
      tiers: const [],
      videoInstructionUrl: null,
      thumbnailInstructionUrl: null,
      instructionsSteps: const {},
      type: type,
    ),
    segments: segments,
  );
}
