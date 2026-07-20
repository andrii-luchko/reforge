import 'dart:async';

import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/audio_feedback_service.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';

class RunningSessionManager {
  RunningSessionManager(
    @Named('pedometer') this._pedometerEngine,
    @Named('gps') this._gpsEngine,
    this._repository,
    this._audioFeedbackService,
  );

  // Use the interface type, not the concrete implementation classes
  final TrackingEngine _pedometerEngine;
  final TrackingEngine _gpsEngine;
  final LocalWorkoutSessionRepository _repository;
  final AudioFeedbackService _audioFeedbackService;

  RunningMode? _currentMode;
  List<LapLimit>? _limits;
  int _currentLapIndex = 0;
  bool _isCompletingLap = false;

  StreamSubscription<RunningMetrics>? _metricsSub;
  final _controller = StreamController<RunningMetrics>.broadcast();
  final _eventsController = StreamController<RunningEvent>.broadcast();

  int? _workoutSessionId;
  int? _programExerciseId;
  int? _currentDbSetId;
  Timer? _snapshotTimer;
  Future<void>? _endSessionFuture;

  // ── Public API for Cubit ───────────────────────────────────────────────────

  Stream<RunningMetrics> get metricsStream => _controller.stream;
  Stream<RunningEvent> get eventsStream => _eventsController.stream;

  RunningMode? get currentMode => _currentMode;

  /// Fetches historical route points for the session.
  Future<List<RouteCoordinate>> getRoutePoints({
    required int sessionId,
    required int programExerciseId,
  }) {
    return _repository.getRoutePoints(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
    );
  }

  Future<void> startSession({
    required RunningMode mode,
    required List<LapLimit> limits,
    required int sessionId,
    required int programExerciseId,
    bool startPaused = false,
  }) async {
    final endingSession = _endSessionFuture;
    if (endingSession != null) await endingSession;

    if (_currentMode != null) {
      logger.w(
        'RunningSessionManager: startSession ignored because a session '
        'is already initialized. Use pauseSession/resumeSession instead.',
      );
      return;
    }

    _currentMode = mode;
    _limits = limits;
    _workoutSessionId = sessionId;
    _programExerciseId = programExerciseId;

    try {
      // Check for an interrupted session lap in the DB
      final inProgressLap = await _repository.getInProgressLapForExercise(
        sessionId: sessionId,
        programExerciseId: programExerciseId,
      );

      RunningMetrics? initialOffset;

      if (inProgressLap != null) {
        // Resume existing lap
        _currentDbSetId = inProgressLap.id;
        _currentLapIndex = inProgressLap.setNumber - 1;

        if (inProgressLap.distanceMeters != null || inProgressLap.durationSeconds != null) {
          initialOffset = RunningMetrics(
            distanceMeters: inProgressLap.distanceMeters ?? 0.0,
            durationSeconds: inProgressLap.durationSeconds ?? 0,
            avgSpeedKmH: inProgressLap.avgSpeedKmH ?? 0.0,
            currentSpeedKmH: inProgressLap.currentSpeedKmH ?? 0.0,
            avgPaceMinKm: inProgressLap.avgPaceMinKm ?? 0.0,
            currentPaceMinKm: inProgressLap.currentPaceMinKm ?? 0.0,
            stepCount: inProgressLap.stepCount ?? 0,
          );
        }
        logger.d('RunningSessionManager: Resuming lap $_currentLapIndex with offset ${initialOffset?.distanceMeters}m');
      } else {
        // Start a fresh lap
        final lastLap = await _repository.getLastLap(
          sessionId: sessionId,
          programExerciseId: programExerciseId,
        );
        _currentLapIndex = lastLap?.setNumber ?? 0;

        final currentLimit = (_limits != null && _currentLapIndex < _limits!.length)
            ? _limits![_currentLapIndex]
            : null;
        _currentDbSetId = await _repository.createNewActiveSet(
          sessionId: _workoutSessionId!,
          programExerciseId: _programExerciseId!,
          setNumber: _currentLapIndex + 1,
          trackingMode: mode.dbValue,
          programSegmentId: currentLimit?.segmentId,
          segmentType: currentLimit?.activityType.name,
        );
        logger.d('RunningSessionManager: Created new lap ${_currentLapIndex + 1} in DB');
      }

      final engine = _getEngineForMode(mode);
      await _metricsSub?.cancel();
      _metricsSub = engine?.metricsStream.listen(
        _onMetricsReceived,
        onError: (Object e, StackTrace st) {
          logger.e('RunningSessionManager: engine stream error', e, st);
          // Propagate typed errors to the UI (RunningTrackerCubit) so it can
          // show an appropriate message. We do NOT stop the session — the
          // engine's internal ticker keeps time even when the sensor fails.
          if (e is SensorUnavailableException) {
            unawaited(endSession());
          }
          _controller.addError(e, st);
        },
        // CRITICAL: never cancel on first error. A GPS glitch or temporary
        // sensor hiccup should not terminate the entire stream pipeline.
        cancelOnError: false,
      );

      // Subscribe before start so synchronous engine errors or an immediate
      // first metric cannot be lost during initialization.
      await engine?.start(initialOffset: initialOffset);
      _startSnapshotTimer();

      if (startPaused) {
        engine?.pause();
      }

      logger.d('RunningSessionManager: Session started with mode $mode (paused: $startPaused)');
    } on Object {
      // A failed start must not leave the manager in a state where every
      // subsequent start is ignored because [_currentMode] is already set.
      await endSession();
      rethrow;
    }
  }

  void pauseSession() {
    _getEngineForMode(_currentMode)?.pause();
  }

  Future<void> resumeSession() async {
    // If resuming from a suspended state (e.g. from summary), we need to create a new DB row
    if (_currentDbSetId == null && _workoutSessionId != null && _programExerciseId != null) {
      final currentLimit = (_limits != null && _currentLapIndex < _limits!.length) ? _limits![_currentLapIndex] : null;
      _currentDbSetId = await _repository.createNewActiveSet(
        sessionId: _workoutSessionId!,
        programExerciseId: _programExerciseId!,
        setNumber: _currentLapIndex + 1,
        trackingMode: _currentMode!.dbValue,
        programSegmentId: currentLimit?.segmentId,
        segmentType: currentLimit?.activityType.name,
      );
      logger.d('RunningSessionManager: Created new lap $_currentLapIndex on resume');
    }

    _getEngineForMode(_currentMode)?.resume();
  }

  Future<void> suspendSessionForSummary() async {
    if (_isCompletingLap || _currentMode == null) return;
    _isCompletingLap = true;

    try {
      logger.d('RunningSessionManager: Suspending session for summary');

      // Pause engine immediately
      _getEngineForMode(_currentMode)?.pause();

      final oldDbSetId = _currentDbSetId;
      _currentDbSetId = null;

      if (oldDbSetId != null) {
        await _writeDriftSnapshot(oldDbSetId);
        await _repository.markSetAsFinishedLocally(oldDbSetId);
      }

      // Check if session was killed during DB writes
      if (_currentMode == null || _workoutSessionId == null) {
        return;
      }

      _currentLapIndex++;
      _getEngineForMode(_currentMode)?.reset();
      _latestMetrics = null;

      // DO NOT create a new active set yet. We leave _currentDbSetId = null.
      // It will be created just-in-time if the user calls resumeSession().
    } finally {
      _isCompletingLap = false;
    }
  }

  void forceNextLap() {
    logger.d('RunningSessionManager: forceNextLap called');
    unawaited(_handleLapCompletion());
  }

  Future<void> endSession() async {
    final inFlight = _endSessionFuture;
    if (inFlight != null) {
      await inFlight;
      return;
    }

    final future = _endSessionInternal();
    _endSessionFuture = future;
    try {
      await future;
    } finally {
      if (identical(_endSessionFuture, future)) {
        _endSessionFuture = null;
      }
    }
  }

  Future<void> _endSessionInternal() async {
    final metricsSub = _metricsSub;
    _metricsSub = null;

    _snapshotTimer?.cancel();
    _snapshotTimer = null;

    final engine = _getEngineForMode(_currentMode);

    await metricsSub?.cancel();
    await engine?.stop();

    _currentMode = null;
    _limits = null;
    _workoutSessionId = null;
    _programExerciseId = null;
    _currentLapIndex = 0;
    _currentDbSetId = null;
    _latestMetrics = null;
    _isCompletingLap = false;
    logger.d('RunningSessionManager: Session ended');
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// Evaluates if the current metric has reached the target limit for the active lap.
  void _onMetricsReceived(RunningMetrics rawMetrics) {
    // Add context to raw metrics
    final currentLimit = (_limits != null && _currentLapIndex < _limits!.length) ? _limits![_currentLapIndex] : null;

    final contextualMetrics = rawMetrics.copyWith(
      currentSegmentIndex: _currentLapIndex,
      segmentId: currentLimit?.segmentId,
      activityType: currentLimit?.activityType ?? SegmentActivity.run,
      // ignore: avoid_redundant_argument_values
      currentSegment: null,
    );

    // Save route point in background if GPS location provided
    if (rawMetrics.currentLocation != null && _workoutSessionId != null) {
      unawaited(
        _repository
            .addRoutePoint(
              sessionId: _workoutSessionId!,
              setId: _currentDbSetId,
              latitude: rawMetrics.currentLocation!.latitude,
              longitude: rawMetrics.currentLocation!.longitude,
              heading: rawMetrics.currentLocation!.heading,
            )
            .catchError((Object e, StackTrace st) {
              // Route point loss is non-critical: the map will have a small gap.
              // We log but do NOT propagate — this must never crash the session.
              logger.w('RunningSessionManager: failed to write route point: $e');
            }),
      );
    }

    _controller.add(contextualMetrics);

    // Write to snapshot timer uses _latestMetrics
    _latestMetrics = contextualMetrics;

    // Evaluate target limit if it exists
    if (currentLimit != null) {
      var limitReached = false;
      switch (currentLimit.metric) {
        case WorkoutMetric.distance:
          if (contextualMetrics.distanceMeters >= currentLimit.limitValue) {
            limitReached = true;
          }
        case WorkoutMetric.time:
          if (contextualMetrics.durationSeconds >= currentLimit.limitValue) {
            limitReached = true;
          }
        // ignore: no_default_cases
        default:
          break;
      }

      if (limitReached) {
        unawaited(_handleLapCompletion());
      }
    }
  }

  RunningMetrics? _latestMetrics;

  void _startSnapshotTimer() {
    _snapshotTimer?.cancel();
    _snapshotTimer = Timer.periodic(
      RunningConstants.dbSnapshotInterval,
      (_) => unawaited(_writeDriftSnapshot(_currentDbSetId)),
    );
  }

  Future<void> _writeDriftSnapshot(int? dbSetId) async {
    final metrics = _latestMetrics;
    if (dbSetId == null || metrics == null) return;

    try {
      await _repository.snapshotActiveLap(
        setId: dbSetId,
        distance: metrics.distanceMeters,
        duration: metrics.durationSeconds,
        avgSpeedKmH: metrics.avgSpeedKmH,
        currentSpeedKmH: metrics.currentSpeedKmH,
        avgPaceMinKm: metrics.avgPaceMinKm,
        currentPaceMinKm: metrics.currentPaceMinKm,
        stepCount: metrics.stepCount,
      );
    } on Exception catch (e, st) {
      // Snapshot failure is non-critical: the next periodic snapshot will
      // overwrite with fresher data. Log and continue.
      logger.w('RunningSessionManager: snapshot write failed (will retry): $e', e, st);
    }
  }

  Future<void> _handleLapCompletion() async {
    if (_isCompletingLap || _currentMode == null) return;
    _isCompletingLap = true;

    try {
      logger.d('RunningSessionManager: Lap $_currentLapIndex completed!');

      final oldDbSetId = _currentDbSetId;
      _currentDbSetId = null;

      // Write final snapshot to local DB and mark as finished locally
      if (oldDbSetId != null) {
        await _writeDriftSnapshot(oldDbSetId);
        await _repository.markSetAsFinishedLocally(oldDbSetId);
      }

      // CRITICAL: Check if the session was ended by the user during the async DB writes!
      if (_currentMode == null || _workoutSessionId == null || _programExerciseId == null) {
        logger.d('RunningSessionManager: Session ended during lap completion. Aborting new lap creation.');
        return;
      }

      _currentLapIndex++;

      // Reset engine physical metrics for the new lap
      _getEngineForMode(_currentMode)?.reset();
      _latestMetrics = null;

      final isPlannedWorkoutCompleted = _limits != null && _currentLapIndex == _limits!.length;
      final currentLimit = (_limits != null && _currentLapIndex < _limits!.length) ? _limits![_currentLapIndex] : null;

      if (isPlannedWorkoutCompleted) {
        // Workout finished!
        unawaited(_audioFeedbackService.playWorkoutCompleted());
        _eventsController.add(const PlannedWorkoutCompletedEvent());
        _getEngineForMode(_currentMode)?.pause();
      } else {
        // Normal lap finished
        unawaited(_audioFeedbackService.playLapCompleted());
        _eventsController.add(
          LapCompletedEvent(
            segmentIndex: _currentLapIndex,
            segmentId: currentLimit?.segmentId,
          ),
        );

        // Start a new row for the new lap
        _currentDbSetId = await _repository.createNewActiveSet(
          sessionId: _workoutSessionId!,
          programExerciseId: _programExerciseId!,
          setNumber: _currentLapIndex + 1,
          trackingMode: _currentMode!.dbValue,
          programSegmentId: currentLimit?.segmentId,
          segmentType: currentLimit?.activityType.name,
        );
      }
    } finally {
      _isCompletingLap = false;
    }
  }

  TrackingEngine? _getEngineForMode(RunningMode? mode) {
    if (mode == null) return null;
    switch (mode) {
      case RunningMode.pedometer:
        return _pedometerEngine;
      case RunningMode.gps:
        return _gpsEngine;
    }
  }
}
