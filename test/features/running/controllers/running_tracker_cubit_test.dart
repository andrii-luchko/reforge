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
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
      ),
    ).thenAnswer((_) async => null);
    when(
      () => repository.getLastLap(
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
      ),
    ).thenAnswer((_) async => null);

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
        exerciseSessionId: any(named: 'exerciseSessionId'),
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
        exerciseSessionId: 20,
        exercise: _programExercise.exerciseDetails,
        segments: const [],
        staticTargetSetCount: 1,
      ),
    )..setMode(RunningMode.gps);
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
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
                exerciseSessionId: 20,
              ),
            ).captured.single
            as List<LapLimit>;
    expect(captured, isEmpty);

    await freeRunCubit.close();
  });

  test('cancel after warm-up never starts a session', () async {
    when(
      () => service.warmUp(mode: any(named: 'mode')),
    ).thenAnswer((_) async {});

    await cubit.warmUpTracking();
    cubit.cancelStart();

    verify(() => service.warmUp(mode: RunningMode.gps)).called(1);
    expect(cubit.state.phase, RunningPhase.overview);
    expect(cubit.state.sessionStatus, RunningSessionStatus.idle);
    verifyNever(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
        startPaused: any(named: 'startPaused'),
      ),
    );
  });

  test('treadmill selection uses 1 km/h default and other modes clear it', () {
    cubit.setMode(RunningMode.treadmill);

    expect(cubit.state.treadmillSpeedKmH, RunningTrackerCubit.defaultTreadmillSpeedKmH);

    cubit.setMode(RunningMode.gps);

    expect(cubit.state.treadmillSpeedKmH, isNull);
  });

  test('treadmill starts with the default speed and confirms runtime changes from metrics', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        initialSpeedKmH: RunningTrackerCubit.defaultTreadmillSpeedKmH,
      ),
    ).thenAnswer((_) async {});
    cubit.setMode(RunningMode.treadmill);

    await cubit.startLap();

    verify(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        initialSpeedKmH: RunningTrackerCubit.defaultTreadmillSpeedKmH,
      ),
    ).called(1);

    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    cubit.setTreadmillSpeedKmH(1.2);

    verify(() => service.setTreadmillSpeed(1.2)).called(1);
    verifyNever(() => service.pauseSession());
    verifyNever(() => service.resumeSession());
    expect(cubit.state.treadmillSpeedKmH, 1);

    metrics.add(_metric.copyWith(currentSpeedKmH: 1.2));
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.treadmillSpeedKmH, 1.2);

    await metrics.close();
  });

  test('paused treadmill accepts speed changes but keeps the paused lap snapshot', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        initialSpeedKmH: RunningTrackerCubit.defaultTreadmillSpeedKmH,
      ),
    ).thenAnswer((_) async {});
    cubit.setMode(RunningMode.treadmill);
    await cubit.startLap();
    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    cubit
      ..pauseLap()
      ..setTreadmillSpeedKmH(1.3);
    metrics.add(
      _metric.copyWith(
        durationSeconds: 99,
        currentSpeedKmH: 1.3,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    verify(() => service.setTreadmillSpeed(1.3)).called(1);
    expect(cubit.state.treadmillSpeedKmH, 1.3);
    expect(cubit.state.currentLap?.durationSeconds, 1);
    expect(cubit.state.isPaused, isTrue);

    await metrics.close();
  });

  test('zero treadmill runtime speed is rejected before dispatch', () {
    cubit.setMode(RunningMode.treadmill);

    expect(() => cubit.setTreadmillSpeedKmH(0), throwsArgumentError);
    verifyNever(() => service.setTreadmillSpeed(any()));
  });

  test('a real start failure returns to overview', () async {
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
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
        exerciseSessionId: 20,
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
        exerciseSessionId: any(named: 'exerciseSessionId'),
        startPaused: any(named: 'startPaused'),
      ),
    );
  });

  test('restore shows paused active state before command dispatch finishes', () async {
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _activeLap);
    final dispatched = Completer<void>();
    when(
      () => service.startSession(
        mode: any(named: 'mode'),
        limits: any(named: 'limits'),
        sessionId: any(named: 'sessionId'),
        exerciseSessionId: any(named: 'exerciseSessionId'),
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
        exerciseSessionId: 20,
        startPaused: true,
      ),
    ).called(1);
  });

  test('treadmill restore sends persisted current speed instead of average speed', () async {
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _activeTreadmillLap);
    when(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        initialSpeedKmH: 9.4,
      ),
    ).thenAnswer((_) async {});

    await cubit.init();

    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.isPaused, isTrue);
    expect(cubit.state.currentLap?.avgSpeedKmH, 7.2);
    expect(cubit.state.currentLap?.currentSpeedKmH, 9.4);
    expect(cubit.state.treadmillSpeedKmH, 9.4);
    verify(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        initialSpeedKmH: 9.4,
      ),
    ).called(1);
  });

  test('treadmill restore without a persisted speed falls back to the product default', () async {
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _activeTreadmillLapWithoutSpeed);
    when(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        initialSpeedKmH: RunningTrackerCubit.defaultTreadmillSpeedKmH,
      ),
    ).thenAnswer((_) async {});

    await cubit.init();

    expect(cubit.state.treadmillSpeedKmH, RunningTrackerCubit.defaultTreadmillSpeedKmH);
    verify(
      () => service.startSession(
        mode: RunningMode.treadmill,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        initialSpeedKmH: RunningTrackerCubit.defaultTreadmillSpeedKmH,
      ),
    ).called(1);
  });

  test('restore opens a completed planned run in resumable summary', () async {
    when(
      () => repository.getLastLap(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _completedLap);
    when(
      () => service.startSession(
        mode: RunningMode.gps,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        restoreCompletedPlan: true,
      ),
    ).thenAnswer((_) async {});
    when(() => service.resumeSession()).thenReturn(null);

    await cubit.init();

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);
    expect(cubit.state.mode, RunningMode.gps);
    expect(cubit.state.isPaused, isTrue);
    expect(cubit.state.canReturnToActive, isTrue);

    cubit.goToActive();
    expect(cubit.state.phase, RunningPhase.active);

    await cubit.resumeLap();
    expect(cubit.state.sessionStatus, RunningSessionStatus.running);
    expect(cubit.state.isPaused, isFalse);
    verify(() => service.resumeSession()).called(1);
  });

  test('completed plan restore failure keeps summary terminal and finishable', () async {
    when(
      () => repository.getLastLap(
        sessionId: 10,
        exerciseSessionId: 20,
      ),
    ).thenAnswer((_) async => _completedLap);
    when(
      () => service.startSession(
        mode: RunningMode.gps,
        limits: any(named: 'limits'),
        sessionId: 10,
        exerciseSessionId: 20,
        startPaused: true,
        restoreCompletedPlan: true,
      ),
    ).thenThrow(
      const RunningServiceException(
        code: 'location_service_disabled',
        message: 'Location is disabled',
        isFatal: true,
      ),
    );

    await cubit.init();

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.terminated);
    expect(cubit.state.terminalFailure?.code, 'location_service_disabled');
    expect(cubit.state.canReturnToActive, isFalse);
    expect(await cubit.finishExercise(), isTrue);
  });

  test('terminal failure turns a restored suspended session into terminated', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(
      () => repository.getInProgressLapForExercise(
        sessionId: 10,
        exerciseSessionId: 20,
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
        exerciseSessionId: any(named: 'exerciseSessionId'),
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

  test('planned completion opens summary without sending manual suspend', () async {
    final metrics = StreamController<RunningMetrics>.broadcast();
    final events = StreamController<RunningEvent>.broadcast();
    when(() => service.metricsStream).thenAnswer((_) => metrics.stream);
    when(() => service.eventsStream).thenAnswer((_) => events.stream);
    when(() => service.resumeSession()).thenReturn(null);
    _stubSuccessfulStart(service);

    await cubit.startLap();
    metrics.add(_metric);
    await Future<void>.delayed(Duration.zero);
    events.add(const PlannedWorkoutCompletedEvent());
    await Future<void>.delayed(Duration.zero);

    expect(cubit.state.phase, RunningPhase.finished);
    expect(cubit.state.sessionStatus, RunningSessionStatus.suspended);
    expect(cubit.state.isPaused, isTrue);
    verifyNever(() => service.suspendSessionForSummary());

    cubit.goToActive();
    await cubit.resumeLap();
    expect(cubit.state.phase, RunningPhase.active);
    expect(cubit.state.isPaused, isFalse);
    verify(() => service.resumeSession()).called(1);

    await metrics.close();
    await events.close();
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
      exerciseSessionId: any(named: 'exerciseSessionId'),
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
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
  setNumber: 1,
  distanceMeters: 30,
  durationSeconds: 12,
  syncStatus: 'tracking',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _completedLap = ActiveRunningSet(
  id: 1,
  sessionId: 10,
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
  setNumber: 1,
  distanceMeters: 3000,
  durationSeconds: 720,
  syncStatus: 'synced',
  trackingMode: 'gps',
  segmentType: 'run',
);

const _activeTreadmillLap = ActiveRunningSet(
  id: 2,
  sessionId: 10,
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf94',
  setNumber: 1,
  distanceMeters: 120,
  durationSeconds: 60,
  avgSpeedKmH: 7.2,
  currentSpeedKmH: 9.4,
  avgPaceMinKm: 60 / 7.2,
  currentPaceMinKm: 60 / 9.4,
  stepCount: 0,
  syncStatus: 'tracking',
  trackingMode: 'treadmill',
  segmentType: 'run',
);

const _activeTreadmillLapWithoutSpeed = ActiveRunningSet(
  id: 3,
  sessionId: 10,
  exerciseSessionId: 20,
  clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf95',
  setNumber: 1,
  distanceMeters: 0,
  durationSeconds: 0,
  syncStatus: 'tracking',
  trackingMode: 'treadmill',
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
  exerciseSessionId: 20,
  exercise: _programExercise.exerciseDetails,
  segments: _programExercise.segments,
  staticTargetSetCount: 1,
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
