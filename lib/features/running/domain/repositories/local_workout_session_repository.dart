import 'package:reforge/core/database/database.dart';

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
  });

  /// Updates the specified set with the latest metrics.
  Future<void> snapshotActiveLap({
    required int setId,
    required double distance,
    required int duration,
    required double pace,
  });

  /// Marks the set as finished locally, signaling the Sync Cubit to push it to the backend.
  Future<void> markSetAsFinishedLocally(int setId);

  /// Retrieves the active/in-progress lap for the session, if any.
  Future<ActiveRunningSet?> getInProgressLap(int sessionId);

  /// Marks the set as completely synced to the backend.
  Future<void> markSetAsDone(int setId);
}
