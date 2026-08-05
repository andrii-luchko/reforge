// ignore_for_file: comment_references

part of 'running_tracker_cubit.dart';

@freezed
sealed class RunningTrackerState with _$RunningTrackerState {
  const RunningTrackerState._();

  const factory RunningTrackerState({
    @Default(RunningPhase.overview) RunningPhase phase,

    /// Lifecycle of the actual engine/background session. This is independent
    /// from [phase], which only chooses the rendered page.
    @Default(RunningSessionStatus.idle) RunningSessionStatus sessionStatus,

    /// Durable description of the failure that permanently closed tracking.
    RunningSessionFailure? terminalFailure,

    /// Selected tracking mode. Null until the user picks one.
    RunningMode? mode,

    /// Last speed confirmed by the treadmill worker, in canonical km/h.
    ///
    /// Fresh treadmill selection starts with the product default before the
    /// worker exists; runtime changes replace it only after a metrics event.
    double? treadmillSpeedKmH,

    // True after check permission.
    @Default(false) bool isPermissionGranted,

    /// The lap currently being tracked. Null when not in active phase.
    ExerciseLap? currentLap,

    /// True when the active lap is paused (tracking stream suspended).
    @Default(false) bool isPaused,

    /// True while a lap or exercise finish is in-flight to the backend.
    @Default(false) bool isSubmitting,

    /// Fires true for exactly one pair of emissions when a lap/segment completes.
    /// UI should handle via [LapCompletedListener] which calls [clearLapCompleted].
    @Default(false) bool lapJustCompleted,

    /// The index of the segment that is NOW active after the last lap completion.
    /// Use this in [LapCompletedListener] to determine which segment finished
    /// (completedIndex = currentSegmentIndex - 1) and what's coming next.
    @Default(0) int currentSegmentIndex,

    /// Non-null when an error has occurred. Cleared on the next action.
    String? error,
  }) = _RunningTrackerState;

  bool get canReturnToActive {
    return phase == RunningPhase.finished && sessionStatus == RunningSessionStatus.suspended;
  }

  bool get canControlTracking => sessionStatus == RunningSessionStatus.running;
}

@freezed
sealed class RunningSessionFailure with _$RunningSessionFailure {
  const factory RunningSessionFailure({
    required String code,
    required String message,
  }) = _RunningSessionFailure;
}
