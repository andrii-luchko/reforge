import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/domain/entities/active_lap.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/running/domain/services/running_tracking_service.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

part 'running_tracker_cubit.freezed.dart';
part 'running_tracker_state.dart';

@injectable
class RunningTrackerCubit extends Cubit<RunningTrackerState> {
  RunningTrackerCubit(
    this._trackingService,
    this._permissionsService,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const RunningTrackerState());

  final RunningTrackingService _trackingService;
  final RunningPermissionsService _permissionsService;

  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  StreamSubscription<RunningMetrics>? _metricsSub;

  Future<void> init() async {
    // For now, start fresh. Background restore logic will be handled by listening to Manager state.
    emit(state.copyWith(phase: RunningPhase.overview));
  }

  void setMode(RunningMode mode) {
    emit(state.copyWith(mode: mode, error: null));
  }

  void cancelPermissionRequest() {
    emit(state.copyWith(phase: RunningPhase.overview));
  }

  Future<void> startLap() async {
    final mode = state.mode;
    if (mode == null) return;

    // Check permissions
    final hasPermission = await _permissionsService.requestPermissionsForMode(mode);
    if (!hasPermission) {
      emit(state.copyWith(phase: RunningPhase.permissionDenied));
      return;
    }

    // Start tracking via Manager
    _trackingService.resetMetrics();

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
      _trackingService.pauseTracking();
      emit(state.copyWith(isPaused: true));
    }
  }

  void resumeLap() {
    if (state.isPaused) {
      _trackingService.resumeTracking();
      emit(state.copyWith(isPaused: false));
    }
  }

  Future<void> forceNextLap() async {
    if (state.isSubmitting) return;
    _trackingService.forceNextLap();
  }

  Future<void> endWorkout() async {
    if (state.isSubmitting) return;
    _stopTracking();
    goToSummary();
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

    // Pass limits to the manager so it acts as a playlist runner
    final limits = programExercise.segments
        .map(
          (s) => LapLimit(
            metric: s.targetMetric,
            limitValue: (s.targetMetric == WorkoutMetric.time ? s.durationSec : s.distanceM).toDouble(),
          ),
        )
        .toList();

    await _trackingService.startTracking(
      mode: mode,
      limits: limits,
      workoutSessionId: workoutSessionId,
      programExerciseId: programExercise.id,
    );

    _metricsSub = _trackingService.metricsStream.listen(
      _onMetricsReceived,
      onError: (Object e) {
        logger.e('RunningTrackerCubit: tracking stream error: $e');
        emit(state.copyWith(error: e.toString()));
      },
    );
  }

  void _onMetricsReceived(RunningMetrics metrics) {
    if (state.isPaused) return;

    emit(
      state.copyWith(
        currentLap: ActiveLap(
          driftSetId: 0, // Manager handles DB IDs now
          lapNumber: metrics.currentSegmentIndex + 1,
          distanceMeters: metrics.distanceMeters,
          durationSeconds: metrics.durationSeconds,
          paceKmH: metrics.paceKmH,
          stepCount: metrics.stepCount,
          activity: SegmentActivity.run, // Free run fallback
        ),
      ),
    );
  }

  void _stopTracking() {
    _trackingService.stopTracking();
    _metricsSub?.cancel();
    _metricsSub = null;
  }

  @override
  Future<void> close() async {
    _stopTracking();
    return super.close();
  }
}
