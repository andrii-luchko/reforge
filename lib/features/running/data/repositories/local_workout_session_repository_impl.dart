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
  Stream<List<ActiveRunningSet>> watchActiveRunningSets(int sessionId) {
    return _db.watchSetsForSession(sessionId);
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
    await _db.into(_db.activeRunningSets).insert(
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
    final row = await _db.getInProgressLap(sessionId);
    return row!.id;
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
    await _db.into(_db.sessionRoutePoints).insert(
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
  Future<List<RouteCoordinate>> getRoutePoints(int sessionId) async {
    final query = _db.select(_db.sessionRoutePoints)
      ..where((tbl) => tbl.sessionId.equals(sessionId))
      ..orderBy([(t) => drift.OrderingTerm(expression: t.timestamp)]);

    final points = await query.get();
    return points
        .map((p) => RouteCoordinate(
              latitude: p.latitude,
              longitude: p.longitude,
              heading: p.heading ?? 0.0,
            ))
        .toList();
  }

  @override
  Future<ActiveRunningSet?> getInProgressLap(int sessionId) {
    return _db.getInProgressLap(sessionId);
  }

  @override
  Future<ActiveRunningSet?> getLastLap(int sessionId) {
    return _db.getLastLap(sessionId);
  }

  @override
  Future<void> markSetAsDone(int setId) {
    return _db.markSetAsDone(setId);
  }
}
