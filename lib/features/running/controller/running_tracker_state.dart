// ignore_for_file: comment_references

part of 'running_tracker_cubit.dart';

@freezed
sealed class RunningTrackerState with _$RunningTrackerState {
  const RunningTrackerState._();

  const factory RunningTrackerState({
    @Default(RunningPhase.overview) RunningPhase phase,

    /// Selected tracking mode. Null until the user picks one.
    RunningMode? mode,

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
}
