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
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/running/domain/services/running_preferences_service.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_flow/domain/entities/exercise_segment_entity.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

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
      emit(state.copyWith(phase: RunningPhase.overview));
    }
  }

  void setMode(RunningMode mode) {
    emit(state.copyWith(mode: mode, error: null));
  }

  void cancelPermissionRequest() {
    cancelStart();
  }

  void cancelStart() {
    emit(
      state.copyWith(
        phase: RunningPhase.overview,
        mode: null,
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
    if (state.phase != RunningPhase.overview) return;

    final mode = state.mode;
    if (mode == null) return;

    if (state.phase == .permissionDenied) return;

    emit(
      state.copyWith(
        phase: RunningPhase.active,
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
    if (!state.isPaused) {
      _serviceClient.pauseSession();
      emit(state.copyWith(isPaused: true, error: null));
    }
  }

  Future<void> resumeLap() async {
    if (state.isPaused) {
      _serviceClient.resumeSession();
      emit(state.copyWith(isPaused: false, error: null));
    }
  }

  Future<void> forceNextLap() async {
    if (state.isSubmitting) return;
    _serviceClient.forceNextLap();
  }

  Future<void> endWorkout() async {
    if (state.isSubmitting) return;

    _serviceClient.suspendSessionForSummary();
    emit(
      state.copyWith(
        isPaused: true,
        currentLap: null,
        error: null,
      ),
    );
    goToSummary();
  }

  void clearLapCompleted() {
    if (state.lapJustCompleted) {
      emit(state.copyWith(lapJustCompleted: false));
    }
  }

  void goToActive() {
    emit(state.copyWith(phase: RunningPhase.active));
  }

  void goToSummary() {
    emit(state.copyWith(phase: RunningPhase.finished));
  }

  Future<bool> finishExercise() async {
    await _stopTracking();
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
      onError: (Object e) {
        logger.e('RunningTrackerCubit: tracking stream error: $e');
        if (e case RunningServiceException(:final isFatal) when isFatal) {
          unawaited(_stopTracking());
          final failedDuringStart = state.phase == RunningPhase.overview;
          emit(
            state.copyWith(
              phase: failedDuringStart ? RunningPhase.overview : RunningPhase.finished,
              mode: null,
              isPermissionGranted: false,
              isPaused: !failedDuringStart,
              currentLap: null,
              error: e.message,
            ),
          );
          return;
        }
        emit(state.copyWith(error: e.toString()));
      },
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
    if (event is LapCompletedEvent) {
      emit(state.copyWith(currentSegmentIndex: event.segmentIndex, lapJustCompleted: true));
      // Immediately reset flag so BlocListener fires only once.
      emit(state.copyWith(lapJustCompleted: false));
    } else if (event is PlannedWorkoutCompletedEvent) {
      unawaited(endWorkout());
    }
  }

  void _onMetricsReceived(RunningMetrics metrics) {
    if (state.isPaused) return;

    final activity = metrics.activityType;

    emit(
      state.copyWith(
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

  Future<void> _stopTracking() async {
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
    await _stopTracking();
    if (!isClosed) {
      emit(
        state.copyWith(
          phase: RunningPhase.overview,
          mode: null,
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
    await _stopTracking();
    return super.close();
  }
}
