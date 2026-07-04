import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/entities/exercise_lap.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/enums/running_phase.dart';
import 'package:reforge/features/running/domain/services/running_permissions_service.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';
import 'package:reforge/features/workout_flow/data/enums/segment_activity.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';

part 'running_tracker_cubit.freezed.dart';
part 'running_tracker_state.dart';

@injectable
class RunningTrackerCubit extends Cubit<RunningTrackerState> {
  RunningTrackerCubit(
    this._sessionManager,
    this._permissionsService,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const RunningTrackerState());

  final RunningSessionManager _sessionManager;
  final RunningPermissionsService _permissionsService;

  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  StreamSubscription<RunningMetrics>? _metricsSub;

  Future<void> init() async {
    final data = await _sessionManager.getRestoredSession(workoutSessionId);

    if (data != null) {
      // Background restore logic: jump to active but paused

      // Calculate real activity from playlist
      final index = data.initialLap.lapNumber - 1;
      final activity = (index < programExercise.segments.length)
          ? programExercise.segments[index].activity
          : SegmentActivity.run;

      final historicalPoints = await _sessionManager.getRoutePoints(workoutSessionId);

      emit(
        state.copyWith(
          phase: RunningPhase.active,
          mode: data.mode,
          isPaused: true,
          error: null,
          currentLap: data.initialLap.copyWith(activity: activity),
          routeMap: historicalPoints,
        ),
      );

      await _subscribeToTracking(data.mode, startPaused: true);
      logger.d('RunningTrackerCubit: restored tracking (mode: ${data.mode.dbValue}) paused');
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

  Future<void> startLap() async {
    final mode = state.mode;
    if (mode == null) return;

    // Check permissions
    final hasPermission = await _permissionsService.requestPermissionsForMode(mode);
    if (!hasPermission) {
      emit(state.copyWith(phase: RunningPhase.permissionDenied));
      return;
    }

    // Start tracking via Manager (metrics get reset in the Manager if fresh)

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
      _sessionManager.pauseSession();
      emit(state.copyWith(isPaused: true));
    }
  }

  Future<void> resumeLap() async {
    if (state.isPaused) {
      await _sessionManager.resumeSession();
      emit(state.copyWith(isPaused: false));
    }
  }

  Future<void> forceNextLap() async {
    if (state.isSubmitting) return;
    _sessionManager.forceNextLap();
  }

  Future<void> endWorkout() async {
    if (state.isSubmitting) return;

    // Suspend instead of stopping. The stream stays alive in case they return.
    await _sessionManager.suspendSessionForSummary();

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

  Future<void> _subscribeToTracking(RunningMode mode, {bool startPaused = false}) async {
    await _metricsSub?.cancel();

    final limits = programExercise.segments
        .map(
          (s) => LapLimit(
            metric: s.targetMetric,
            limitValue: s.targetMetric == WorkoutMetric.time
                ? s.durationSec.toDouble()
                : s.distanceM.toDouble(),
          ),
        )
        .toList();

    await _sessionManager.startSession(
      mode: mode,
      limits: limits,
      sessionId: workoutSessionId,
      programExerciseId: programExercise.id,
      startPaused: startPaused,
    );

    _metricsSub = _sessionManager.metricsStream.listen(
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

    final currentRoute = List<RouteCoordinate>.from(state.routeMap);
    if (metrics.currentLocation != null) {
      if (currentRoute.isEmpty || 
          currentRoute.last.latitude != metrics.currentLocation!.latitude || 
          currentRoute.last.longitude != metrics.currentLocation!.longitude) {
        currentRoute.add(metrics.currentLocation!);
      }
    }

    emit(
      state.copyWith(
        currentLap: ExerciseLap(
          driftSetId: 0, // Manager handles DB IDs now
          lapNumber: metrics.currentSegmentIndex + 1,
          distanceMeters: metrics.distanceMeters,
          durationSeconds: metrics.durationSeconds,
          paceKmH: metrics.paceKmH,
          stepCount: metrics.stepCount,
          activity: activity,
        ),
        routeMap: currentRoute,
      ),
    );
  }

  void _stopTracking() {
    _sessionManager.endSession();
    unawaited(_metricsSub?.cancel());
    _metricsSub = null;
  }

  @override
  Future<void> close() async {
    _stopTracking();
    return super.close();
  }
}
