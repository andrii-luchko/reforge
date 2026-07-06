import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/data/services/running_service_client.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
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
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const RunningTrackerState());

  final RunningServiceClient _serviceClient;
  final LocalWorkoutSessionRepository _repository;
  final RunningPermissionsService _permissionsService;

  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  StreamSubscription<RunningMetrics>? _metricsSub;

  ExerciseSegmentEntity? get currentSegment => programExercise.segments.elementAtOrNull(state.currentSegmentIndex);

  Future<void> init() async {
    final isServiceRunning = await _serviceClient.isRunning;
    final lap = await _repository.getInProgressLap(workoutSessionId);

    if (isServiceRunning || lap != null) {
      // Background restore logic: jump to active but paused
      final modeStr = lap?.trackingMode ?? RunningMode.gps.dbValue;
      final mode = RunningMode.values.firstWhere(
        (m) => m.dbValue == modeStr,
        orElse: () => RunningMode.gps,
      );

      // Calculate real activity from playlist
      final index = (lap?.setNumber ?? 1) - 1;
      final activity = (index < programExercise.segments.length)
          ? programExercise.segments[index].activity
          : SegmentActivity.run;

      emit(
        state.copyWith(
          phase: RunningPhase.active,
          mode: mode,
          isPaused: true,
          error: null,
          currentLap: ExerciseLap(
            driftSetId: lap?.id ?? 0,
            lapNumber: index + 1,
            distanceMeters: lap?.distanceMeters ?? 0.0,
            durationSeconds: lap?.durationSeconds ?? 0,
            avgSpeedKmH: lap?.avgSpeedKmH ?? 0.0,
            currentSpeedKmH: lap?.currentSpeedKmH ?? 0.0,
            avgPaceMinKm: lap?.avgPaceMinKm ?? 0.0,
            currentPaceMinKm: lap?.currentPaceMinKm ?? 0.0,
            activity: activity,
          ),
        ),
      );

      // We call startSession, which either spins up the service (if killed)
      // or just attaches metrics if it is already running.
      await _subscribeToTracking(mode);
      // Wait for service to process before pausing
      await Future.delayed(const Duration(milliseconds: 300));
      _serviceClient.pauseSession(); // Pause it safely

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
    emit(state.copyWith(phase: RunningPhase.overview));
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

  Future<void> startLap() async {
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

    await _subscribeToTracking(mode);
    logger.d('RunningTrackerCubit: started tracking (mode: ${mode.dbValue})');
  }

  void pauseLap() {
    if (!state.isPaused) {
      _serviceClient.pauseSession();
      emit(state.copyWith(isPaused: true));
    }
  }

  Future<void> resumeLap() async {
    if (state.isPaused) {
      _serviceClient.resumeSession();
      emit(state.copyWith(isPaused: false));
    }
  }

  Future<void> forceNextLap() async {
    if (state.isSubmitting) return;
    _serviceClient.forceNextLap();
  }

  Future<void> endWorkout() async {
    if (state.isSubmitting) return;

    // Suspend instead of stopping. The stream stays alive in case they return.
    _serviceClient.suspendSessionForSummary();

    // Reset pause state so if they return and press resume, it works properly.
    // Wait, if they return to active, should it be paused? Yes, the engine is paused.
    emit(state.copyWith(isPaused: true));

    goToSummary();
  }

  /// Called by [LapCompletedListener] as a safety net to ensure
  /// [RunningTrackerState.lapJustCompleted] is reset after handling.
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
    _stopTracking();
    return true;
  }

  Future<void> _subscribeToTracking(RunningMode mode) async {
    await _metricsSub?.cancel();

    final limits = programExercise.segments
        .map(
          (s) => LapLimit(
            metric: s.targetMetric,
            limitValue: s.targetMetric == WorkoutMetric.time ? s.durationSec.toDouble() : s.distanceM.toDouble(),
          ),
        )
        .toList();

    await _serviceClient.startSession(
      mode: mode,
      limits: limits,
      sessionId: workoutSessionId,
      programExerciseId: programExercise.id,
    );

    _metricsSub = _serviceClient.metricsStream.listen(
      _onMetricsReceived,
      onError: (Object e) {
        logger.e('RunningTrackerCubit: tracking stream error: $e');
        emit(state.copyWith(error: e.toString()));
      },
    );
  }

  void _onMetricsReceived(RunningMetrics metrics) {
    if (state.isPaused) return;

    // A lap just completed — update segment index, fire the event, then reset.
    // The next normal emission will carry fresh metrics for the new segment.
    if (metrics.lapJustCompleted) {
      final newIndex = metrics.currentSegmentIndex;
      emit(state.copyWith(currentSegmentIndex: newIndex, lapJustCompleted: true));
      // Immediately reset flag so BlocListener fires only once.
      emit(state.copyWith(lapJustCompleted: false));
      return;
    }

    final index = metrics.currentSegmentIndex;
    final activity = (index < programExercise.segments.length)
        ? programExercise.segments[index].activity
        : SegmentActivity.run;

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

  void _stopTracking() {
    _serviceClient.endSession();
    unawaited(_metricsSub?.cancel());
    _metricsSub = null;
  }

  @override
  Future<void> close() async {
    _stopTracking();
    return super.close();
  }
}
