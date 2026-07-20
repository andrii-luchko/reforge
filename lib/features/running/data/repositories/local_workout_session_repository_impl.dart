import 'package:drift/drift.dart' as drift;
import 'package:injectable/injectable.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';

@LazySingleton(as: LocalWorkoutSessionRepository)
class LocalWorkoutSessionRepositoryImpl implements LocalWorkoutSessionRepository {
  LocalWorkoutSessionRepositoryImpl(this._db);

  final WorkoutDatabase _db;

  @override
  Stream<List<ActiveRunningSet>> watchActiveRunningSets({
    required int sessionId,
    required int programExerciseId,
  }) {
    return _db.watchSetsForExercise(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
    );
  }

  @override
  Future<int> createNewActiveSet({
    required int sessionId,
    required int programExerciseId,
    required int setNumber,
    required String trackingMode,
    int? programSegmentId,
    String? segmentType,
  }) async {
    return _db
        .into(_db.activeRunningSets)
        .insert(
          ActiveRunningSetsCompanion.insert(
            sessionId: sessionId,
            programExerciseId: programExerciseId,
            setNumber: setNumber,
            isBusy: const drift.Value(true),
            isDone: const drift.Value(false),
            trackingMode: drift.Value(trackingMode),
            programSegmentId: drift.Value(programSegmentId),
            segmentType: segmentType != null ? drift.Value(segmentType) : const drift.Value.absent(),
          ),
        );
  }

  @override
  Future<void> snapshotActiveLap({
    required int setId,
    required double distance,
    required int duration,
    required double avgSpeedKmH,
    required double currentSpeedKmH,
    required double avgPaceMinKm,
    required double currentPaceMinKm,
    required int stepCount,
  }) {
    return _db.snapshotActiveLap(
      setId: setId,
      distance: distance,
      duration: duration,
      avgSpeedKmH: avgSpeedKmH,
      currentSpeedKmH: currentSpeedKmH,
      avgPaceMinKm: avgPaceMinKm,
      currentPaceMinKm: currentPaceMinKm,
      stepCount: stepCount,
    );
  }

  @override
  Future<void> markSetAsFinishedLocally(int setId) {
    return _db.markSetAsFinishedLocally(setId);
  }

  @override
  Future<void> addRoutePoint({
    required int sessionId,
    required int? setId,
    required double latitude,
    required double longitude,
    required double heading,
  }) async {
    await _db
        .into(_db.sessionRoutePoints)
        .insert(
          SessionRoutePointsCompanion.insert(
            sessionId: sessionId,
            setId: drift.Value(setId),
            latitude: latitude,
            longitude: longitude,
            heading: drift.Value(heading),
            timestamp: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Future<List<RouteCoordinate>> getRoutePoints({
    required int sessionId,
    required int programExerciseId,
  }) async {
    final query =
        _db.select(_db.sessionRoutePoints).join([
            drift.innerJoin(
              _db.activeRunningSets,
              _db.sessionRoutePoints.setId.equalsExp(_db.activeRunningSets.id),
            ),
          ])
          ..where(
            _db.sessionRoutePoints.sessionId.equals(sessionId) &
                _db.activeRunningSets.programExerciseId.equals(programExerciseId),
          )
          ..orderBy([drift.OrderingTerm(expression: _db.sessionRoutePoints.timestamp)]);

    final rows = await query.get();
    final points = rows.map((row) => row.readTable(_db.sessionRoutePoints));
    return points
        .map(
          (p) => RouteCoordinate(
            latitude: p.latitude,
            longitude: p.longitude,
            heading: p.heading ?? 0.0,
          ),
        )
        .toList();
  }

  @override
  Future<ActiveRunningSet?> getInProgressLapForExercise({
    required int sessionId,
    required int programExerciseId,
  }) {
    return _db.getInProgressLapForExercise(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
    );
  }

  @override
  Future<ActiveRunningSet?> getAnyInProgressLapForSession(int sessionId) {
    return _db.getAnyInProgressLapForSession(sessionId);
  }

  @override
  Future<ActiveRunningSet?> getLastLap({
    required int sessionId,
    required int programExerciseId,
  }) {
    return _db.getLastLap(
      sessionId: sessionId,
      programExerciseId: programExerciseId,
    );
  }

  @override
  Future<void> markSetAsDone(int setId) {
    return _db.markSetAsDone(setId);
  }
}
