import 'dart:async';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/data/services/pedometer_tracking_service.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_tracking_service.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

@LazySingleton(as: RunningTrackingService)
class RunningTrackingManager implements RunningTrackingService {
  RunningTrackingManager(this._pedometerService, this._repository);

  final PedometerTrackingService _pedometerService;
  final LocalWorkoutSessionRepository _repository;

  RunningMode? _currentMode;
  List<LapLimit>? _limits;
  int _currentLapIndex = 0;

  StreamSubscription<RunningMetrics>? _metricsSub;
  final _controller = StreamController<RunningMetrics>.broadcast();

  int? _workoutSessionId;
  int? _programExerciseId;
  int? _currentDbSetId;
  Timer? _snapshotTimer;

  // ── RunningTrackingService ─────────────────────────────────────────────────

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  RunningMode? get currentMode => _currentMode;

  @override
  Future<void> startTracking({
    required RunningMode mode,
    required List<LapLimit> limits,
    RunningMetrics? initialOffset,
    int? workoutSessionId,
    int? programExerciseId,
  }) async {
    if (_currentMode != null) return;

    _currentMode = mode;
    _limits = limits;
    _currentLapIndex = 0;
    _workoutSessionId = workoutSessionId;
    _programExerciseId = programExerciseId;

    if (_workoutSessionId != null && _programExerciseId != null) {
      _currentDbSetId = await _repository.createNewActiveSet(
        sessionId: _workoutSessionId!,
        programExerciseId: _programExerciseId!,
        setNumber: _currentLapIndex + 1,
        trackingMode: mode.dbValue,
      );
    }

    final service = _getServiceForMode(mode);
    
    await service?.startTracking(
      mode: mode,
      limits: limits, // Passed down but mostly ignored by leaf trackers
      initialOffset: initialOffset,
    );

    _metricsSub = service?.metricsStream.listen(_onMetricsReceived);
    _startSnapshotTimer();
    logger.d('RunningTrackingManager: Started tracking with mode $mode and ${limits.length} limits.');
  }

  @override
  void pauseTracking() {
    _getServiceForMode(_currentMode)?.pauseTracking();
  }

  @override
  void resumeTracking() {
    _getServiceForMode(_currentMode)?.resumeTracking();
  }

  @override
  void forceNextLap() {
    logger.d('RunningTrackingManager: forceNextLap called');
    _handleLapCompletion();
  }

  @override
  void stopTracking() {
    _metricsSub?.cancel();
    _metricsSub = null;
    _snapshotTimer?.cancel();
    _snapshotTimer = null;

    _getServiceForMode(_currentMode)?.stopTracking();

    _currentMode = null;
    _limits = null;
    _currentLapIndex = 0;
    _currentDbSetId = null;
  }

  @override
  void resetMetrics() {
    _getServiceForMode(_currentMode)?.resetMetrics();
  }

  // ── Private ────────────────────────────────────────────────────────────────

  /// Evaluates if the current metric has reached the target limit for the active lap.
  void _onMetricsReceived(RunningMetrics rawMetrics) {
    // We add the current lap index context to the raw metrics so the UI knows which lap we are on.
    final contextualMetrics = rawMetrics.copyWith(
      currentSegmentIndex: _currentLapIndex,
      // currentSegment is now null because the tracker is decoupled from ExerciseSegmentEntity
      currentSegment: null, 
    );

    _controller.add(contextualMetrics);

    // Write to snapshot timer uses _latestMetrics
    _latestMetrics = contextualMetrics;

    // Evaluate target limit if it exists
    final currentLimit = (_limits != null && _currentLapIndex < _limits!.length)
        ? _limits![_currentLapIndex]
        : null;

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
        _handleLapCompletion();
      }
    }
  }

  RunningMetrics? _latestMetrics;

  void _startSnapshotTimer() {
    _snapshotTimer?.cancel();
    _snapshotTimer = Timer.periodic(const Duration(seconds: 5), (_) => unawaited(_writeDriftSnapshot(_currentDbSetId)));
  }

  Future<void> _writeDriftSnapshot(int? dbSetId) async {
    final metrics = _latestMetrics;
    if (dbSetId == null || metrics == null) return;

    await _repository.snapshotActiveLap(
      setId: dbSetId,
      distance: metrics.distanceMeters,
      duration: metrics.durationSeconds,
      pace: metrics.paceKmH,
    );
  }

  Future<void> _handleLapCompletion() async {
    logger.d('RunningTrackingManager: Lap $_currentLapIndex completed!');

    // 1. Play sound
    unawaited(SystemSound.play(SystemSoundType.alert));

    // 2. Clear current ID immediately to prevent race conditions with incoming ticks
    final oldDbSetId = _currentDbSetId;
    _currentDbSetId = null;

    // 3. Write final snapshot to local DB and mark as finished locally
    if (oldDbSetId != null) {
      await _writeDriftSnapshot(oldDbSetId);
      await _repository.markSetAsFinishedLocally(oldDbSetId);
    }

    // 4. Move to next lap (infinite free run if limits are exhausted)
    _currentLapIndex++;
    
    // Reset physical metrics (distance, duration) for the new lap
    resetMetrics();

    // Start a new row for the new lap
    if (_workoutSessionId != null && _programExerciseId != null) {
      _currentDbSetId = await _repository.createNewActiveSet(
        sessionId: _workoutSessionId!,
        programExerciseId: _programExerciseId!,
        setNumber: _currentLapIndex + 1,
        trackingMode: _currentMode!.dbValue,
      );
    }
  }

  RunningTrackingService? _getServiceForMode(RunningMode? mode) {
    if (mode == null) return null;
    switch (mode) {
      case RunningMode.pedometer:
      case RunningMode.gps:
        // Currently fallback to pedometer for both until GPS is ready
        return _pedometerService;
    }
  }
}
