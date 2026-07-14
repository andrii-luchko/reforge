/// Domain-level exceptions for the running tracking module.
///
/// These wrap lower-level platform/database exceptions into typed errors
/// that the UI layer (Cubit) can catch and display as meaningful messages,
/// rather than showing raw `PlatformException` or `SqliteException` text.
library;

/// Thrown when a hardware sensor required for tracking is unavailable.
///
/// Examples:
/// - Step counter not present on the device (simulator, some tablets).
/// - Pedometer permission denied.
///
/// This is a *non-recoverable* error for the current session — the engine
/// cannot produce metrics without the sensor.
class SensorUnavailableException implements Exception {
  const SensorUnavailableException(this.sensor, {this.cause});

  /// Human-readable sensor name, e.g. 'pedometer', 'gps'.
  final String sensor;

  /// Original platform exception, if any.
  final Object? cause;

  @override
  String toString() => 'SensorUnavailableException: $sensor is not available. cause=$cause';
}

/// A recoverable failure in a tracking sensor stream.
class SensorStreamException implements Exception {
  const SensorStreamException(this.sensor, {this.cause});

  final String sensor;
  final Object? cause;

  @override
  String toString() => 'SensorStreamException: $sensor stream failed. cause=$cause';
}

/// A tracking failure transported between the background isolate and the UI.
class RunningServiceException implements Exception {
  const RunningServiceException({
    required this.code,
    required this.message,
    required this.isFatal,
  });

  final String code;
  final String message;
  final bool isFatal;

  @override
  String toString() => message;
}

/// Thrown when a critical write to the local database fails.
///
/// "Critical" means the session manager cannot continue without the written
/// data (e.g. failing to create a new lap row means we have no ID to snapshot
/// against).
///
/// Non-critical writes (snapshots, route points) are swallowed with a log.
class DatabaseWriteException implements Exception {
  const DatabaseWriteException(this.operation, {this.cause});

  /// Name of the DB operation that failed, e.g. 'createNewActiveSet'.
  final String operation;

  /// Original Drift/SQLite exception, if any.
  final Object? cause;

  @override
  String toString() => 'DatabaseWriteException: $operation failed. cause=$cause';
}

/// Thrown when the background service fails to start within the handshake
/// timeout window.
class ServiceStartTimeoutException implements Exception {
  const ServiceStartTimeoutException();

  @override
  String toString() => 'ServiceStartTimeoutException: background service did not signal ready in time.';
}
