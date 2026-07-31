import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/enums/running_session_status.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/running/domain/services/running_preferences_service.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_program/domain/enums/workout_metrics.dart';

part 'running_tracker_cubit.freezed.dart';
part 'running_tracker_state.dart';

@injectable
class RunningTrackerCubit extends Cubit<RunningTrackerState> {
  RunningTrackerCubit(
    this._serviceClient,
    this._repository,
    this._permissionsService,
    this._preferencesService,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const RunningTrackerState());

  final RunningServiceClient _serviceClient;
  final LocalWorkoutSessionRepository _repository;
  final RunningPermissionsService _permissionsService;
  final RunningPreferencesService _preferencesService;

  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  StreamSubscription<RunningMetrics>? _metricsSub;
  StreamSubscription<RunningEvent>? _eventsSub;
  bool _hasSentStopSession = false;

  ExerciseSegmentEntity? get currentSegment => programExercise.segments.elementAtOrNull(state.currentSegmentIndex);

  bool get hasSeenAudioHint => _preferencesService.hasSeenAudioHint;

  Future<void> markAudioHintSeen() async {
    await _preferencesService.markAudioHintSeen();
  }

  Future<void> init() async {
    final lap = await _repository.getInProgressLapForExercise(
      sessionId: workoutSessionId,
      programExerciseId: programExercise.id,
    );

    if (lap != null) {
      // Background restore logic: jump to active but paused
      final modeStr = lap.trackingMode ?? RunningMode.gps.dbValue;
      final mode = RunningMode.values.firstWhere(
        (m) => m.dbValue == modeStr,
        orElse: () => RunningMode.gps,
      );

      // Calculate real activity from playlist
      final index = lap.setNumber - 1;
      final activity = (index < programExercise.segments.length)
          ? programExercise.segments[index].activity
          : SegmentActivity.run;

      final restoredLap = ExerciseLap(
        driftSetId: lap.id,
        lapNumber: index + 1,
        distanceMeters: lap.distanceMeters ?? 0.0,
        durationSeconds: lap.durationSeconds ?? 0,
        avgSpeedKmH: lap.avgSpeedKmH ?? 0.0,
        currentSpeedKmH: lap.currentSpeedKmH ?? 0.0,
        avgPaceMinKm: lap.avgPaceMinKm ?? 0.0,
        currentPaceMinKm: lap.currentPaceMinKm ?? 0.0,
        activity: activity,
      );

      emit(
        state.copyWith(
          phase: RunningPhase.active,
          mode: mode,
          sessionStatus: RunningSessionStatus.suspended,
          terminalFailure: null,
          isPaused: true,
          error: null,
          currentLap: restoredLap,
        ),
      );

      try {
        await _subscribeToTracking(mode, startPaused: true);
      } on Object catch (error, stackTrace) {
        logger.e('RunningTrackerCubit: failed to restore tracking', error, stackTrace);
        await _handleStartFailure(error);
        return;
      }

      logger.d('RunningTrackerCubit: restored tracking (mode: ${mode.dbValue}) paused');
    } else {
      // Start fresh
      emit(
        state.copyWith(
          phase: RunningPhase.overview,
          sessionStatus: RunningSessionStatus.idle,
          terminalFailure: null,
        ),
      );
    }
  }

  void setMode(RunningMode mode) {
    emit(
      state.copyWith(
        mode: mode,
        sessionStatus: RunningSessionStatus.idle,
        terminalFailure: null,
        error: null,
      ),
    );
  }

  void cancelPermissionRequest() {
    cancelStart();
  }

  void cancelStart() {
    emit(
      state.copyWith(
        phase: RunningPhase.overview,
        mode: null,
        sessionStatus: RunningSessionStatus.idle,
        terminalFailure: null,
        isPermissionGranted: false,
        error: null,
      ),
    );
  }

  Future<void> askPermissions() async {
    final mode = state.mode;
    if (mode == null) return;

    final hasPermission = await _permissionsService.requestPermissionsForMode(mode);
    if (!hasPermission) {
      emit(state.copyWith(phase: RunningPhase.permissionDenied));
    } else {
      emit(state.copyWith(isPermissionGranted: true));
    }
  }

  /// Best-effort worker warm-up. It never starts a tracking engine.
  Future<void> warmUpTracking() => _serviceClient.warmUp();

  Future<void> startLap() async {
    if (state.phase != RunningPhase.overview || state.sessionStatus != RunningSessionStatus.idle) return;

    final mode = state.mode;
    if (mode == null) return;

    if (state.phase == .permissionDenied) return;

    emit(
      state.copyWith(
        phase: RunningPhase.active,
        sessionStatus: RunningSessionStatus.starting,
        terminalFailure: null,
        isPaused: false,
        error: null,
      ),
    );

    try {
      await _subscribeToTracking(mode);
    } on Object catch (error, stackTrace) {
      logger.e('RunningTrackerCubit: failed to start tracking', error, stackTrace);
      await _handleStartFailure(error);
      return;
    }

    logger.d('RunningTrackerCubit: started tracking (mode: ${mode.dbValue})');
  }

  void pauseLap() {
    if (!state.canControlTracking || state.isPaused) return;
    _serviceClient.pauseSession();
    emit(state.copyWith(isPaused: true, error: null));
  }

  Future<void> resumeLap() async {
    final canResume =
        state.sessionStatus == RunningSessionStatus.running || state.sessionStatus == RunningSessionStatus.suspended;
    if (!state.isPaused || !canResume || state.phase != RunningPhase.active) return;

    _serviceClient.resumeSession();
    emit(
      state.copyWith(
        sessionStatus: RunningSessionStatus.running,
        isPaused: false,
        error: null,
      ),
    );
  }

  Future<void> forceNextLap() async {
    if (state.isSubmitting || !state.canControlTracking || state.isPaused) return;
    _serviceClient.forceNextLap();
  }

  Future<void> endWorkout() async {
    if (state.isSubmitting || !state.canControlTracking) return;

    _serviceClient.suspendSessionForSummary();
    emit(
      state.copyWith(
        phase: RunningPhase.finished,
        sessionStatus: RunningSessionStatus.suspended,
        terminalFailure: null,
        isPaused: true,
        currentLap: null,
        error: null,
      ),
    );
  }

  void clearLapCompleted() {
    if (state.lapJustCompleted) {
      emit(state.copyWith(lapJustCompleted: false));
    }
  }

  void goToActive() {
    if (!state.canReturnToActive) return;
    emit(state.copyWith(phase: RunningPhase.active));
  }

  Future<bool> finishExercise() async {
    await _closeTrackingSession();
    return true;
  }

  Future<void> _subscribeToTracking(
    RunningMode mode, {
    bool startPaused = false,
  }) async {
    // A real start failure may be retried by the same Cubit instance.
    _hasSentStopSession = false;
    await _metricsSub?.cancel();
    await _eventsSub?.cancel();

    final limits = programExercise.segments
        .map(
          (s) => LapLimit(
            metric: s.targetMetric,
            limitValue: s.targetMetric == WorkoutMetric.time ? s.durationSec.toDouble() : s.distanceM.toDouble(),
            segmentId: s.id,
            activityType: s.activity,
          ),
        )
        .toList();

    _metricsSub = _serviceClient.metricsStream.listen(
      _onMetricsReceived,
      onError: _onTrackingError,
    );
    _eventsSub = _serviceClient.eventsStream.listen(
      _onEventReceived,
      onError: (Object e) {
        logger.e('RunningTrackerCubit: events stream error: $e');
      },
    );

    await _serviceClient.startSession(
      mode: mode,
      limits: limits,
      sessionId: workoutSessionId,
      programExerciseId: programExercise.id,
      startPaused: startPaused,
    );
  }

  void _onEventReceived(RunningEvent event) {
    if (state.sessionStatus == RunningSessionStatus.terminated) return;

    if (event is LapCompletedEvent) {
      emit(state.copyWith(currentSegmentIndex: event.segmentIndex, lapJustCompleted: true));
      // Immediately reset flag so BlocListener fires only once.
      emit(state.copyWith(lapJustCompleted: false));
    } else if (event is PlannedWorkoutCompletedEvent) {
      unawaited(endWorkout());
    }
  }

  void _onMetricsReceived(RunningMetrics metrics) {
    final sessionStatus = state.sessionStatus;
    if (state.isPaused ||
        (sessionStatus != RunningSessionStatus.starting && sessionStatus != RunningSessionStatus.running)) {
      return;
    }

    final activity = metrics.activityType;

    emit(
      state.copyWith(
        sessionStatus: sessionStatus == RunningSessionStatus.starting ? RunningSessionStatus.running : sessionStatus,
        currentLap: ExerciseLap(
          driftSetId: 0, // Manager handles DB IDs now
          lapNumber: metrics.currentSegmentIndex + 1,
          distanceMeters: metrics.distanceMeters,
          durationSeconds: metrics.durationSeconds,
          avgSpeedKmH: metrics.avgSpeedKmH,
          currentSpeedKmH: metrics.currentSpeedKmH,
          avgPaceMinKm: metrics.avgPaceMinKm,
          currentPaceMinKm: metrics.currentPaceMinKm,
          stepCount: metrics.stepCount,
          activity: activity,
        ),
      ),
    );
  }

  void _onTrackingError(Object error) {
    if (isClosed || state.sessionStatus == RunningSessionStatus.terminated) return;
    logger.e('RunningTrackerCubit: tracking stream error: $error');

    if (error case RunningServiceException(:final isFatal) when isFatal) {
      final failedDuringStart = state.sessionStatus == RunningSessionStatus.starting;
      emit(
        state.copyWith(
          phase: failedDuringStart ? RunningPhase.overview : RunningPhase.finished,
          mode: failedDuringStart ? null : state.mode,
          sessionStatus: RunningSessionStatus.terminated,
          terminalFailure: RunningSessionFailure(
            code: error.code,
            message: error.message,
          ),
          isPermissionGranted: false,
          isPaused: false,
          currentLap: null,
          error: error.message,
        ),
      );

      // Do not await cancellation from inside the subscription's own onError
      // callback. The state is terminal immediately; cleanup is defensive and
      // idempotent because the background manager may already be stopped.
      unawaited(_closeTrackingSession());
      return;
    }

    emit(state.copyWith(error: error.toString()));
  }

  /// Closes the UI-side stream subscriptions and sends a best-effort,
  /// idempotent stop command to the background session.
  Future<void> _closeTrackingSession() async {
    if (!_hasSentStopSession) {
      _hasSentStopSession = true;
      _serviceClient.endSession();
    }

    final metricsSub = _metricsSub;
    final eventsSub = _eventsSub;
    _metricsSub = null;
    _eventsSub = null;

    await metricsSub?.cancel();
    await eventsSub?.cancel();
  }

  Future<void> _handleStartFailure(Object error) async {
    await _closeTrackingSession();
    if (!isClosed) {
      emit(
        state.copyWith(
          phase: RunningPhase.overview,
          mode: null,
          sessionStatus: RunningSessionStatus.idle,
          terminalFailure: null,
          isPermissionGranted: false,
          isPaused: false,
          currentLap: null,
          error: error.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _closeTrackingSession();
    return super.close();
  }
}
