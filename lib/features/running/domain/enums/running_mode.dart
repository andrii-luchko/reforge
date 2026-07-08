/// Identifies the data source used for tracking a running lap.
enum RunningMode {
  /// Outdoor run — uses GPS (geolocator) for distance and pace.
  gps,

  /// Treadmill run — uses the device pedometer (step counter) for distance.
  pedometer;

  String get dbValue => switch (this) {
    RunningMode.gps => 'gps',
    RunningMode.pedometer => 'pedometer',
  };

  static RunningMode? fromDb(String? value) => switch (value) {
    'gps' => RunningMode.gps,
    'pedometer' => RunningMode.pedometer,
    _ => null,
  };
}
