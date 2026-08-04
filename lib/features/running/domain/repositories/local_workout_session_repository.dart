import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';

/// Repository for managing the local/offline state of a workout session (Drift).
/// Used by the running tracker to take snapshots and coordinate active laps.
abstract interface class LocalWorkoutSessionRepository {
  /// Returns the running sets owned by one exercise session.
  Stream<List<ActiveRunningSet>> watchActiveRunningSets({
    required int sessionId,
    required int exerciseSessionId,
    int? workoutProgramExerciseId,
  });

  /// Creates a new active set in the database for tracking.
  Future<int> createNewActiveSet({
    required int sessionId,
    required int exerciseSessionId,
    required int setNumber,
    required String trackingMode,
    int? workoutProgramExerciseId,
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

  /// Fetches GPS points owned by one exercise session.
  Future<List<RouteCoordinate>> getRoutePoints({
    required int sessionId,
    required int exerciseSessionId,
    int? workoutProgramExerciseId,
  });

  /// Returns the in-progress lap for one program exercise, if any.
  Future<ActiveRunningSet?> getInProgressLapForExercise({
    required int sessionId,
    required int exerciseSessionId,
    int? workoutProgramExerciseId,
  });

  /// Returns any in-progress lap in the session for restore discovery only.
  Future<ActiveRunningSet?> getAnyInProgressLapForSession(int sessionId);

  /// Returns the last lap for one program exercise, regardless of status.
  Future<ActiveRunningSet?> getLastLap({
    required int sessionId,
    required int exerciseSessionId,
    int? workoutProgramExerciseId,
  });

  Future<void> markSetAsSyncing(int setId);

  Future<void> markSetSyncFailed(int setId);

  /// Stores backend identity and marks the local outbox row as synced.
  Future<void> markSetAsSynced(int setId, {required int remoteSetId});

  /// Makes rows left in `syncing` after process death eligible for retry.
  Future<void> recoverInterruptedSetSyncs();
}
