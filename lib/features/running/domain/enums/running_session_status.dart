/// Lifecycle of the tracking session, independent from the page currently
/// rendered by the running flow.
enum RunningSessionStatus {
  /// No tracking session has been dispatched.
  idle,

  /// The start command was dispatched but no metric has confirmed the engine
  /// is producing data yet.
  starting,

  /// A live engine exists. Manual pause is represented separately by
  /// `RunningTrackerState.isPaused`.
  running,

  /// The live engine is retained for an explicit return from the summary.
  suspended,

  /// The engine and background session have been permanently closed.
  terminated,
}
