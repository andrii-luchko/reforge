import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_exercise_spec.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_source.dart';

void main() {
  group('WorkoutExecutionPlan', () {
    test('adapts a program day while preserving order and program metadata', () {
      final firstSegment = ExerciseSegmentEntity(
        id: 40,
        order: 1,
        activity: SegmentActivity.run,
        targetMetric: WorkoutMetric.time,
        distanceM: 0,
        durationSec: 60,
        recommendedSpeed: null,
      );
      final day = ProgramDayEntity(
        id: 25,
        name: 'Day 1',
        dayNumber: 1,
        programExercises: [
          const ProgramExerciseEntity(
            id: 102,
            programDayId: 25,
            sets: 2,
            order: 2,
            exerciseDetails: _strengthExercise,
            executionMode: ExecutionMode.standard,
            segments: [],
          ),
          ProgramExerciseEntity(
            id: 101,
            programDayId: 25,
            sets: 3,
            order: 1,
            exerciseDetails: _runningExercise,
            executionMode: ExecutionMode.segmented,
            segments: [firstSegment],
          ),
        ],
      );

      final plan = WorkoutExecutionPlan.fromProgramDay(day);

      expect((plan.source as ProgramWorkoutSource).programDayId, 25);
      expect(plan.exercises.map((item) => item.exerciseId), [4, 8]);

      final first = plan.exercises.first;
      expect(first.executionKey, 'program:25:exercise:101');
      expect(first.targetSetCount, 3);
      expect(first.segments, [firstSegment]);
      expect(first.details, same(_runningExercise));
      expect(first.workoutProgramExerciseId, 101);
      expect(first.programBinding?.programDayId, 25);
      expect(first.programBinding?.order, 1);
      expect(first.programBinding?.executionMode, ExecutionMode.segmented);
      expect(first.isRunningExercise, isTrue);
    });

    test('creates an unbound one-exercise Free Run plan from catalog details', () {
      final plan = WorkoutExecutionPlan.freeRun(
        details: _runningExercise,
        executionKey: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
      );

      expect(plan.source, isA<AdHocWorkoutSource>());
      expect(plan.exercises, hasLength(1));
      expect(plan.exercises.single.exerciseId, WorkoutExecutionPlan.freeRunExerciseId);
      expect(plan.exercises.single.executionKey, '019893a2-7078-76f9-8e8f-bf8e3b16bf93');
      expect(plan.exercises.single.workoutProgramExerciseId, isNull);
      expect(plan.exercises.single.programBinding, isNull);
      expect(plan.exercises.single.targetSetCount, isNull);
      expect(plan.exercises.single.segments, isEmpty);
      expect(plan.exercises.single.isRunningExercise, isTrue);
    });

    test('uses executionKey rather than exerciseId as execution identity', () {
      const first = WorkoutExerciseSpec(
        executionKey: 'builder:first',
        details: _runningExercise,
        targetSetCount: null,
        segments: [],
        programBinding: null,
      );
      const second = WorkoutExerciseSpec(
        executionKey: 'builder:second',
        details: _runningExercise,
        targetSetCount: null,
        segments: [],
        programBinding: null,
      );

      final plan = WorkoutExecutionPlan.adHoc(exercises: [first, second]);

      expect(plan.exercises.map((item) => item.exerciseId), [4, 4]);
      expect(plan.exercises.map((item) => item.executionKey).toSet(), hasLength(2));
      expect(() => plan.exercises.add(first), throwsUnsupportedError);
    });

    test('binds backend runtime IDs to a spec without changing the plan', () {
      final spec = WorkoutExecutionPlan.freeRun(
        details: _runningExercise,
        executionKey: 'free-run',
      ).exercises.single;

      final execution = ActiveExerciseExecution(
        spec: spec,
        workoutSessionId: 182,
        session: _exerciseSession,
      );

      expect(execution.spec, same(spec));
      expect(execution.workoutSessionId, 182);
      expect(execution.exerciseSessionId, 246);
    });

    test('rejects a non-Running catalog exercise in the Free Run factory', () {
      expect(
        () => WorkoutExecutionPlan.freeRun(
          details: _strengthExercise,
          executionKey: 'invalid',
        ),
        throwsArgumentError,
      );
    });
  });
}

const _exerciseSession = WorkoutExerciseSessionEntity(
  id: 246,
  exerciseId: 4,
  workoutSessionId: 182,
  workoutProgramExerciseId: null,
  isSwapped: false,
  swappedExerciseId: null,
  isActive: true,
  notes: null,
  lastCompletedSet: null,
  createdAt: null,
  updatedAt: null,
  sets: [],
  exercise: null,
  swappedExercise: null,
);

const _runningExercise = ExerciseDetailsEntity(
  id: 4,
  name: 'Running',
  description: 'Run',
  key: null,
  factionId: 3,
  metrics: [WorkoutMetric.time, WorkoutMetric.distance],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);

const _strengthExercise = ExerciseDetailsEntity(
  id: 8,
  name: 'Squats',
  description: 'Squat',
  key: 'squats',
  metrics: [WorkoutMetric.reps, WorkoutMetric.weight],
  poseDetectionPreset: null,
  isTiered: false,
  tiers: [],
  videoInstructionUrl: null,
  thumbnailInstructionUrl: null,
  instructionsSteps: {},
);
