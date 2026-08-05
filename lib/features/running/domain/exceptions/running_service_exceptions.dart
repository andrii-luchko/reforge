/// Domain-level exceptions for the running tracking module.
///
/// These wrap lower-level platform/database exceptions into typed errors
/// that the UI layer (Cubit) can catch and display as meaningful messages,
/// rather than showing raw `PlatformException` or `SqliteException` text.
library;

/// Tracking engine that can no longer produce valid metrics for this session.
enum TrackingEngineType { gps, treadmill, pedometer }

/// Required platform dependency whose loss stopped a tracking engine.
enum TrackingDependency { location, motion, clock }

/// Stable, transport-safe reason why a tracking engine stopped.
enum TrackingEngineFailureReason {
  locationServiceDisabled,
  locationPermissionDenied,
  motionPermissionDenied,
  sensorUnavailable,
  streamClosed,
  unrecoverableStreamFailure,
}

/// A terminal tracking failure.
///
/// Once emitted through the engine metrics stream, no more metrics will be
/// produced by that engine instance until a new session is started.
class TrackingEngineFailureException implements Exception {
  const TrackingEngineFailureException({
    required this.engine,
    required this.dependency,
    required this.reason,
    this.cause,
  });

  final TrackingEngineType engine;
  final TrackingDependency dependency;
  final TrackingEngineFailureReason reason;
  final Object? cause;

  @override
  String toString() {
    return 'TrackingEngineFailureException: ${engine.name} stopped because '
        '${dependency.name}/${reason.name}. cause=$cause';
  }
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

/// Thrown when an isolate message does not match the running service protocol.
class ServiceProtocolException implements Exception {
  const ServiceProtocolException({
    required this.key,
    required this.expectedType,
    required this.actualValue,
  });

  final String key;
  final String expectedType;
  final Object? actualValue;

  @override
  String toString() {
    final actualType = actualValue?.runtimeType.toString() ?? 'null';
    return 'Invalid running service payload: "$key" must be $expectedType, got $actualType.';
  }
}
