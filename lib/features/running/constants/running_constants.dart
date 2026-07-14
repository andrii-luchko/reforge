class RunningConstants {
  /// The global interval at which tracking engines (GPS, Pedometer)
  /// tick to update metrics like duration and pace.
  static const Duration engineTickInterval = Duration(seconds: 1);

  /// How often the manager writes a snapshot of the current lap to the database
  /// to prevent data loss in case of a crash.
  static const Duration dbSnapshotInterval = Duration(seconds: 5);

  /// Average human stride length in meters, used by the pedometer engine.
  static const double defaultStrideMeters = 0.78;

  // ── Notifications ─────────────────────────────────────────────────────────

  static const String notificationChannelId = 'running_tracker';
  static const String notificationTitle = 'Reforge';
  static const String notificationText = 'Tracking your run';

  // ── GPS Specific ──────────────────────────────────────────────────────────

  /// The minimum distance in meters the user must move before a new
  /// GPS coordinate is considered valid (before Kalman filter).
  static const double gpsDistanceFilterMeters = 2;

  /// A point less accurate than this cannot reliably contribute to run distance.
  static const double maxGpsAccuracyMeters = 50;

  /// Default camera zoom level when actively tracking the user on the map.
  static const double mapCameraZoomActive = 17.5;

  // ── Kalman Filter Tuning ──────────────────────────────────────────────────

  /// Process noise variance (acceleration noise in m/s^2).
  /// Lower trusts constant velocity more, higher trusts raw GPS more.
  static const double kalmanAccelNoise = 2;

  /// The minimum acceptable accuracy (in meters) for a GPS fix.
  static const double kalmanMinAccuracy = 3;

  /// Mahalanobis distance threshold for rejecting a GPS fix as an outlier.
  static const double kalmanGatingThreshold = 9;

  // ── Session Recovery ──────────────────────────────────────────────────────

  /// Maximum time a GPS session can be dormant (app killed / no GPS signal)
  /// before it is considered stale and auto-finished on the next app launch.
  ///
  /// If `DateTime.now() - lastKnownTimestamp > maxSessionStaleness`,
  /// the background service will call auto-finish instead of restoring.
  static const Duration maxSessionStaleness = Duration(hours: 4);

  /// Maximum plausible human movement speed in km/h, used to detect
  /// "teleportation" after an app kill (e.g. user got in a car or a plane).
  ///
  /// If the straight-line speed between the last saved coordinate and the
  /// current GPS fix exceeds this value, the gap is ignored and the session
  /// resumes from the current position without adding the phantom distance.
  static const double maxHumanSpeedKmh = 35;
}
