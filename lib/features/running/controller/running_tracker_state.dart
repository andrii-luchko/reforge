part of 'running_tracker_cubit.dart';

@freezed
sealed class RunningTrackerState with _$RunningTrackerState {
  const RunningTrackerState._();

  const factory RunningTrackerState({
    @Default(RunningPhase.overview) RunningPhase phase,

    /// Selected tracking mode. Null until the user picks one.
    RunningMode? mode,

    /// The lap currently being tracked. Null when not in active phase.
    ExerciseLap? currentLap,

    /// True when the active lap is paused (tracking stream suspended).
    @Default(false) bool isPaused,

    /// True while a lap or exercise finish is in-flight to the backend.
    @Default(false) bool isSubmitting,

    /// The historical and live route coordinates for the current session.
    @Default([]) List<RouteCoordinate> routeMap,

    /// Non-null when an error has occurred. Cleared on the next action.
    String? error,
  }) = _RunningTrackerState;
}
