import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/controller/running_set_sync_cubit.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(WorkoutSet(id: -1));
  });

  test('maps local running rows and marks a successful backend sync as done', () async {
    final rows = StreamController<List<ActiveRunningSet>>();
    final localRepository = _MockLocalWorkoutSessionRepository();
    final exerciseRepository = _MockExerciseSessionRepository();
    final markedDone = Completer<void>();

    when(
      () => localRepository.watchActiveRunningSets(
        sessionId: 10,
        programExerciseId: 20,
      ),
    ).thenAnswer((_) => rows.stream);
    when(
      () => exerciseRepository.completeSet(
        exerciseId: 30,
        workoutSessionId: 10,
        workoutProgramExerciseId: 20,
        system: MeasurementSystem.metric,
        set: any(named: 'set'),
      ),
    ).thenAnswer((_) async => const Result.success(null));
    when(() => localRepository.markSetAsDone(1)).thenAnswer((_) async {
      if (!markedDone.isCompleted) markedDone.complete();
    });

    final cubit = RunningSetSyncCubit(
      localRepository,
      exerciseRepository,
      10,
      _runningProgramExercise,
    )..init();

    rows.add(const [_readyToSyncRow]);
    await markedDone.future.timeout(const Duration(seconds: 1));

    expect(cubit.state.sets, hasLength(1));
    expect(cubit.state.sets.single.distance, 1.5);
    expect(cubit.state.sets.single.time, const Duration(seconds: 300));
    expect(cubit.state.sets.single.isDone, isTrue);
    verify(() => localRepository.markSetAsDone(1)).called(1);

    await cubit.close();
    await rows.close();
  });
}

class _MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class _MockExerciseSessionRepository extends Mock implements ExerciseSessionRepository {}

const _readyToSyncRow = ActiveRunningSet(
  id: 1,
  sessionId: 10,
  programExerciseId: 20,
  setNumber: 1,
  distanceMeters: 1500,
  durationSeconds: 300,
  avgSpeedKmH: 9,
  isDone: false,
  isBusy: false,
  trackingMode: 'gps',
  segmentType: 'run',
);

const _runningProgramExercise = ProgramExerciseEntity(
  id: 20,
  programDayId: 1,
  sets: 1,
  order: 1,
  executionMode: ExecutionMode.segmented,
  exerciseDetails: ExerciseDetailsEntity(
    id: 30,
    name: 'Run',
    description: 'Run',
    key: 'run',
    metrics: [WorkoutMetric.time, WorkoutMetric.distance],
    poseDetectionPreset: null,
    isTiered: false,
    tiers: [],
    videoInstructionUrl: null,
    thumbnailInstructionUrl: null,
    instructionsSteps: {},
  ),
  segments: [],
);
