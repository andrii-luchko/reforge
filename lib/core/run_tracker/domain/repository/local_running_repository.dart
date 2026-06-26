import 'package:reforge/features/workout_common/models/workout_set.dart';

abstract interface class LocalRunningRepository {
  /// Emits real-time updates for the active workout session
  Stream<List<WorkoutSet>> watchActiveSession(int sessionId);

  /// Marks a specific interval/lap as completed
  Future<void> markSetAsDone(int setId);

  /// Creates the next empty interval in the local database
  Future<void> createNextSet({required int sessionId, required int setNumber});

  /// Used exclusively by the background isolate to push new sensor data
  Future<void> updateActiveSetMetrics({
    required int setId,
    required double distanceMeters,
    required int durationSeconds,
    required double paceKmH,
  });
}
