import 'package:injectable/injectable.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';

@LazySingleton(as: LocalWorkoutSessionRepository)
class LocalWorkoutSessionRepositoryImpl implements LocalWorkoutSessionRepository {
  LocalWorkoutSessionRepositoryImpl(this._db);

  final WorkoutDatabase _db;

  @override
  Stream<List<ActiveRunningSet>> watchActiveRunningSets(int sessionId) {
    return _db.watchSetsForSession(sessionId);
  }

  @override
  Future<int> createNewActiveSet({
    required int sessionId,
    required int programExerciseId,
    required int setNumber,
    required String trackingMode,
  }) async {
    await _db.createNewActiveSet(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
      setNumber: setNumber,
      trackingMode: trackingMode,
    );
    final row = await _db.getInProgressLap(sessionId);
    return row!.id;
  }

  @override
  Future<void> snapshotActiveLap({
    required int setId,
    required double distance,
    required int duration,
    required double pace,
  }) {
    return _db.snapshotActiveLap(
      setId: setId,
      distance: distance,
      duration: duration,
      pace: pace,
    );
  }

  @override
  Future<void> markSetAsFinishedLocally(int setId) {
    return _db.markSetAsFinishedLocally(setId);
  }

  @override
  Future<ActiveRunningSet?> getInProgressLap(int sessionId) {
    return _db.getInProgressLap(sessionId);
  }

  @override
  Future<void> markSetAsDone(int setId) {
    return _db.markSetAsDone(setId);
  }
}
