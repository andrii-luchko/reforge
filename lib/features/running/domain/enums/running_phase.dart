// ignore_for_file: comment_references

/// Drives the [RunningExerciseHost] to switch between pages.
enum RunningPhase {
  /// Overview page: notes, exercise details, "Start Running" button.
  overview,

  /// Live tracking: real-time metrics, completed laps list, pause/resume.
  active,

  /// Summary page: all completed laps, aggregate stats, "Finish Exercise".
  finished,

  /// Permission denied placeholder screen.
  permissionDenied,
}
