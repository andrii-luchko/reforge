class RunningConstants {
  /// The global interval at which tracking engines (GPS, Pedometer)
  /// tick to update metrics like duration and pace.
  static const Duration engineTickInterval = Duration(seconds: 1);

  /// How often the manager writes a snapshot of the current lap to the database
  /// to prevent data loss in case of a crash.
  static const Duration dbSnapshotInterval = Duration(seconds: 5);

  /// Average human stride length in meters, used by the pedometer engine.
  static const double defaultStrideMeters = 0.78;

  // ── GPS Specific ──────────────────────────────────────────────────────────

  /// The minimum distance in meters the user must move before a new
  /// GPS coordinate is considered valid (before Kalman filter).
  static const double gpsDistanceFilterMeters = 2;

  /// Default camera zoom level when actively tracking the user on the map.
  static const double mapCameraZoomActive = 17;

  // ── Kalman Filter Tuning ──────────────────────────────────────────────────

  /// Process noise variance (acceleration noise in m/s^2).
  /// Lower trusts constant velocity more, higher trusts raw GPS more.
  static const double kalmanAccelNoise = 2;

  /// The minimum acceptable accuracy (in meters) for a GPS fix.
  static const double kalmanMinAccuracy = 3;

  /// Mahalanobis distance threshold for rejecting a GPS fix as an outlier.
  static const double kalmanGatingThreshold = 9;
}
