/// Identifies the data source used for tracking a running lap.
enum RunningMode {
  /// Outdoor run — uses GPS (geolocator) for distance and pace.
  gps,

  /// Treadmill run — uses a manually configured treadmill speed.
  treadmill,

  /// Treadmill run — uses the device pedometer (step counter) for distance.
  ///
  /// Kept for restoring legacy sessions and as a temporary rollback path.
  pedometer;

  String get dbValue => switch (this) {
    RunningMode.gps => 'gps',
    RunningMode.treadmill => 'treadmill',
    RunningMode.pedometer => 'pedometer',
  };

  static RunningMode? fromDb(String? value) => switch (value) {
    'gps' => RunningMode.gps,
    'treadmill' => RunningMode.treadmill,
    'pedometer' => RunningMode.pedometer,
    _ => null,
  };
}
