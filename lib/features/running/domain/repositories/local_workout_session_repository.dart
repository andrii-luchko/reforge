import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';

/// Repository for managing the local/offline state of a workout session (Drift).
/// Used by the running tracker to take snapshots and coordinate active laps.
abstract interface class LocalWorkoutSessionRepository {
  /// Returns a stream of ActiveRunningSets for the given workout session.
  Stream<List<ActiveRunningSet>> watchActiveRunningSets(int sessionId);

  /// Creates a new active set in the database for tracking.
  Future<int> createNewActiveSet({
    required int sessionId,
    required int programExerciseId,
    required int setNumber,
    required String trackingMode,
    int? programSegmentId,
    String? segmentType,
  });

  /// Updates the specified set with the latest metrics.
  Future<void> snapshotActiveLap({
    required int setId,
    required double distance,
    required int duration,
    required double avgSpeedKmH,
    required double currentSpeedKmH,
    required double avgPaceMinKm,
    required double currentPaceMinKm,
    required int stepCount,
  });

  /// Marks the set as finished locally, signaling the Sync Cubit to push it to the backend.
  Future<void> markSetAsFinishedLocally(int setId);

  /// Saves a single GPS coordinate to the database.
  Future<void> addRoutePoint({
    required int sessionId,
    required int? setId,
    required double latitude,
    required double longitude,
    required double heading,
  });

  /// Fetches all historical GPS points for a given session.
  Future<List<RouteCoordinate>> getRoutePoints(int sessionId);

  /// Returns the in-progress (isBusy = true) running set/lap, if any.
  Future<ActiveRunningSet?> getInProgressLap(int sessionId);

  /// Returns the last lap (highest setNumber) for this session, regardless of status.
  Future<ActiveRunningSet?> getLastLap(int sessionId);

  /// Marks the set as completely synced to the backend.
  Future<void> markSetAsDone(int setId);
}
