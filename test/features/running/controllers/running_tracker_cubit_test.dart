import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/running/domain/services/running_preferences_service.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(RunningMode.gps);
    registerFallbackValue(<LapLimit>[]);
  });

  late MockRunningServiceClient service;
  late MockLocalWorkoutSessionRepository repository;
  late RunningTrackerCubit cubit;

  setUp(() {
    service = MockRunningServiceClient();
    repository = MockLocalWorkoutSessionRepository();
    when(() => service.metricsStream).thenAnswer((_) => const Stream<RunningMetrics>.empty());
    when(() => service.eventsStream).thenAnswer((_) => const Stream<RunningEvent>.empty());
    when(() => service.endSession()).thenReturn(null);

    cubit = RunningTrackerCubit(
      service,
      repository,
      MockRunningPermissionsService(),
      MockRunningPreferencesService(),
      10,
      _programExercise,
    )..setMode(RunningMode.gps);
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  test('enters active before startSession finishes', () async {
    final dispatched = Completer<void>();
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    ).thenAnswer((_) => dispatched.future);

    final start = cubit.startLap();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.isPaused, false);

    dispatched.complete();
    await start;
  });

  test('cancel after warm-up never starts a session', () async {
    when(() => service.warmUp()).thenAnswer((_) async {});

    await cubit.warmUpTracking();
    cubit.cancelStart();

    expect(cubit.state.phase, RunningPhase.overview);
    verifyNever(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    );
  });

  test('a real start failure returns to overview', () async {
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    ).thenThrow(
      const RunningServiceException(
        code: 'background_service_start_failed',
        message: 'Could not start',
        isFatal: true,
      ),
    );

    await cubit.startLap();

    expect(cubit.state.phase, RunningPhase.overview);
    expect(cubit.state.mode, isNull);
    expect(cubit.state.error, 'Could not start');
  });

  test('idle worker without an in-progress lap does not trigger restore', () async {
    when(() => repository.getInProgressLap(10)).thenAnswer((_) async => null);

    await cubit.init();

    expect(cubit.state.phase, RunningPhase.overview);
    verifyNever(() => service.isRunning);
    verifyNever(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    );
  });

  test('restore shows paused active state before command dispatch finishes', () async {
    when(() => repository.getInProgressLap(10)).thenAnswer((_) async => _activeLap);
    final dispatched = Completer<void>();
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    ).thenAnswer((_) => dispatched.future);

    final restore = cubit.init();
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.isPaused, true);
    expect(cubit.state.currentLap?.durationSeconds, 12);

    dispatched.complete();
    await restore;
    verify(
      () => service.startSession(
        mode: RunningMode.gps,
        limits: any(named: 'limits'),
        sessionId: 10,
        programExerciseId: 20,
        startPaused: true,
      ),
    ).called(1);
  });

  test('finishExercise followed by close sends stop_session once', () async {
    await cubit.finishExercise();
    await cubit.close();

    verify(() => service.endSession()).called(1);
  });
}

class MockRunningServiceClient extends Mock implements RunningServiceClient {}

class MockLocalWorkoutSessionRepository extends Mock implements LocalWorkoutSessionRepository {}

class MockRunningPermissionsService extends Mock implements RunningPermissionsService {}

class MockRunningPreferencesService extends Mock implements RunningPreferencesService {}

const _activeLap = ActiveRunningSet(
  id: 1,
  sessionId: 10,
  programExerciseId: 20,
  setNumber: 1,
  distanceMeters: 30,
  durationSeconds: 12,
  isDone: false,
  isBusy: true,
  trackingMode: 'gps',
  segmentType: 'run',
);

final _programExercise = ProgramExerciseEntity(
  id: 20,
  programDayId: 1,
  sets: 1,
  order: 1,
  executionMode: ExecutionMode.segmented,
  exerciseDetails: const ExerciseDetailsEntity(
    id: 30,
    name: 'Run',
    description: 'Run',
    key: 'run',
    metrics: [WorkoutMetric.time],
    poseDetectionPreset: null,
    isTiered: false,
    tiers: [],
    videoInstructionUrl: null,
    thumbnailInstructionUrl: null,
    instructionsSteps: {},
  ),
  segments: [
    ExerciseSegmentEntity(
      id: 40,
      order: 1,
      activity: SegmentActivity.run,
      targetMetric: WorkoutMetric.time,
      distanceM: 0,
      durationSec: 60,
    ),
  ],
);
