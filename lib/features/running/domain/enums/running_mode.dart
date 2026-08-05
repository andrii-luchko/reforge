/// Identifies the data source used for tracking a running lap.
enum RunningMode {
  /// Outdoor run — uses GPS (geolocator) for distance and pace.
  gps,

  /// Treadmill run — uses a manually configured treadmill speed.
  treadmill;

  String get dbValue => switch (this) {
    RunningMode.gps => 'gps',
    RunningMode.treadmill => 'treadmill',
  };

  static RunningMode? fromDb(String? value) => switch (value) {
    'gps' => RunningMode.gps,
    'treadmill' || 'pedometer' => RunningMode.treadmill,
    _ => null,
  };
}
