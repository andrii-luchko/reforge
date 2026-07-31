import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/controller/running_tracker_cubit.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/enums/running_session_status.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/running/domain/services/running_preferences_service.dart';
import 'package:reforge/features/workout_program/data/enums/execution_mode.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

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
      _runningConfig,
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
    expect(cubit.state.sessionStatus, RunningSessionStatus.starting);
    expect(cubit.state.isPaused, false);

    dispatched.complete();
    await start;
  });

  test('free-run runtime config starts without segment limits', () async {
    final freeRunCubit = RunningTrackerCubit(
      service,
      repository,
      MockRunningPermissionsService(),
      MockRunningPreferencesService(),
      RunningExerciseConfig(
        workoutSessionId: 10,
        workoutProgramExerciseId: _programExercise.id,
        exercise: _programExercise.exerciseDetails,
        segments: const [],
      ),
    )..setMode(RunningMode.gps);
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    ).thenAnswer((_) async {});

    await freeRunCubit.startLap();

    final captured =
        verify(
              () => service.startSession(
                mode: RunningMode.gps,
                limits: captureAny(named: 'limits'),
                sessionId: 10,
                programExerciseId: 20,
              ),
            ).captured.single
            as List<LapLimit>;
    expect(captured, isEmpty);

    await freeRunCubit.close();
  });

  test('cancel after warm-up never starts a session', () async {
    when(() => service.warmUp()).thenAnswer((_) async {});

    await cubit.warmUpTracking();
    cubit.cancelStart();

    expect(cubit.state.phase, RunningPhase.overview);
    expect(cubit.state.sessionStatus, RunningSessionStatus.idle);
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
    expect(cubit.state.sessionStatus, RunningSessionStatus.idle);
    expect(cubit.state.terminalFailure, isNull);
    expect(cubit.state.mode, isNull);
    expect(cubit.state.error, 'Could not start');
  });

  test('idle worker without an in-progress lap does not trigger restore', () async {
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        programExerciseId: 20,
      ),
    ).thenAnswer((_) async => null);

    await cubit.init();

    expect(cubit.state.phase, RunningPhase.overview);
    expect(cubit.state.sessionStatus, RunningSessionStatus.idle);
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
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        programExerciseId: 20,
      ),
    ).thenAnswer((_) async => _activeLap);
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
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);
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

  test('terminal failure turns a restored suspended session into terminated', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        programExerciseId: 20,
      ),
    ).thenAnswer((_) async => _activeLap);
    _stubSuccessfulStart(service);

    await cubit.init();
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);

    metrics.addError(
      const RunningServiceException(
        code: 'location_permission_denied',
        message: 'Location permission was removed. Tracking has stopped.',
        isFatal: true,
      ),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.terminated);
    expect(cubit.state.terminalFailure?.code, 'location_permission_denied');
    expect(cubit.state.canReturnToActive, false);

    await metrics.close();
  });

  test('finishExercise followed by close sends stop_session once', () async {
    await cubit.finishExercise();
    await cubit.close();

    verify(() => service.endSession()).called(1);
  });

  test('first metric confirms that a starting session is running', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        programExerciseId: any(named: 'programExerciseId'),
        startPaused: any(named: 'startPaused'),
      ),
    ).thenAnswer((_) async {});

    await cubit.startLap();
    expect(cubit.state.sessionStatus, RunningSessionStatus.starting);

    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.sessionStatus, RunningSessionStatus.running);
    expect(cubit.state.currentLap?.durationSeconds, 1);

    await metrics.close();
  });

  test('terminal failure before the first metric returns to overview', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    _stubSuccessfulStart(service);

    await cubit.startLap();
    metrics.addError(
      const RunningServiceException(
        code: 'location_service_disabled',
        message: 'Location services were turned off. Tracking has stopped.',
        isFatal: true,
      ),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.overview);
    expect(cubit.state.sessionStatus, RunningSessionStatus.terminated);
    expect(cubit.state.mode, isNull);
    expect(cubit.state.terminalFailure?.code, 'location_service_disabled');
    expect(cubit.state.currentLap, isNull);
    expect(cubit.state.error, 'Location services were turned off. Tracking has stopped.');
    verify(() => service.endSession()).called(1);

    await metrics.close();
  });

  test('runtime terminal failure opens non-resumable summary and blocks controls', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    _stubSuccessfulStart(service);

    await cubit.startLap();
    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    metrics.addError(
      const RunningServiceException(
        code: 'motion_permission_denied',
        message: 'Motion permission was removed. Tracking has stopped.',
        isFatal: true,
      ),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.terminated);
    expect(cubit.state.mode, RunningMode.gps);
    expect(cubit.state.canReturnToActive, false);
    expect(cubit.state.terminalFailure?.code, 'motion_permission_denied');

    cubit
      ..goToActive()
      ..pauseLap();
    await cubit.resumeLap();
    await cubit.forceNextLap();
    await cubit.endWorkout();

    expect(cubit.state.phase, RunningPhase.finished);
    verifyNever(() => service.pauseSession());
    verifyNever(() => service.resumeSession());
    verifyNever(() => service.forceNextLap());
    verifyNever(() => service.suspendSessionForSummary());
    verify(() => service.endSession()).called(1);

    await metrics.close();
  });

  test('normal summary remains resumable', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    _stubSuccessfulStart(service);

    await cubit.startLap();
    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    await cubit.endWorkout();

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);
    expect(cubit.state.canReturnToActive, true);
    expect(cubit.state.terminalFailure, isNull);

    cubit.goToActive();
    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);

    await cubit.resumeLap();
    expect(cubit.state.sessionStatus, RunningSessionStatus.running);
    expect(cubit.state.isPaused, false);
    verify(service.suspendSessionForSummary).called(1);
    verify(service.resumeSession).called(1);

    await metrics.close();
  });

  test('recoverable error does not change the session lifecycle', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    _stubSuccessfulStart(service);

    await cubit.startLap();
    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    metrics.addError(
      const RunningServiceException(
        code: 'sensor_stream_error',
        message: 'A tracking sensor is temporarily unavailable.',
        isFatal: false,
      ),
      StackTrace.current,
    );
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.sessionStatus, RunningSessionStatus.running);
    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.terminalFailure, isNull);

    await metrics.close();
  });
}

void _stubSuccessfulStart(MockRunningServiceClient service) {
  when(
    () => service.startSession(
      mode: any(named: 'mode'),
      limits: any(named: 'limits'),
      sessionId: any(named: 'sessionId'),
      programExerciseId: any(named: 'programExerciseId'),
      startPaused: any(named: 'startPaused'),
    ),
  ).thenAnswer((_) async {});
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

final _runningConfig = RunningExerciseConfig(
  workoutSessionId: 10,
  workoutProgramExerciseId: _programExercise.id,
  exercise: _programExercise.exerciseDetails,
  segments: _programExercise.segments,
);

const _metric = RunningMetrics(
  distanceMeters: 1,
  durationSeconds: 1,
  avgSpeedKmH: 1,
  currentSpeedKmH: 1,
  avgPaceMinKm: 1,
  currentPaceMinKm: 1,
  stepCount: 1,
);
