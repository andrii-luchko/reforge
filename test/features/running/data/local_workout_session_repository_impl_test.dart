import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/data/repositories/local_workout_session_repository_impl.dart';
import 'package:reforge/features/running/domain/services/client_id_generator.dart';

void main() {
  late WorkoutDatabase database;
  late LocalWorkoutSessionRepositoryImpl repository;

  setUp(() async {
    database = WorkoutDatabase(NativeDatabase.memory());
    repository = LocalWorkoutSessionRepositoryImpl(database, const ClientIdGenerator());
    await database
        .into(database.workoutSessionCache)
        .insert(
          WorkoutSessionCacheCompanion.insert(
            remoteSessionId: 10,
            programDayId: const Value(30),
            startedAt: DateTime(2026),
          ),
        );
  });

  tearDown(() => database.close());

  test('scopes watched, active, last, and synced laps by exercise session', () async {
    final firstExerciseLap1 = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    final firstExerciseLap2 = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 2,
      trackingMode: 'gps',
    );
    final secondExerciseLap1 = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 111,
      setNumber: 1,
      trackingMode: 'pedometer',
    );

    final firstRows = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;
    final secondRows = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 111).first;

    expect(firstRows.map((row) => row.id), [firstExerciseLap1, firstExerciseLap2]);
    expect(secondRows.map((row) => row.id), [secondExerciseLap1]);
    expect(
      (await repository.getLastLap(sessionId: 10, exerciseSessionId: 110))?.setNumber,
      2,
    );
    expect(
      (await repository.getLastLap(sessionId: 10, exerciseSessionId: 111))?.setNumber,
      1,
    );

    await repository.markSetAsFinishedLocally(firstExerciseLap1);
    await repository.markSetAsSyncing(firstExerciseLap1);
    await repository.markSetAsSynced(firstExerciseLap1, remoteSetId: 901);
    final completed = await database.getCompletedLapsForExercise(
      sessionId: 10,
      exerciseSessionId: 110,
    );
    expect(completed.map((row) => row.id), [firstExerciseLap1]);
    expect(completed.single.remoteSetId, 901);
  });

  test('returns route points only for the requested program exercise', () async {
    final firstExerciseSet = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    final secondExerciseSet = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 111,
      setNumber: 1,
      trackingMode: 'gps',
    );

    await repository.addRoutePoint(
      sessionId: 10,
      setId: firstExerciseSet,
      latitude: 50,
      longitude: 30,
      heading: 10,
    );
    await repository.addRoutePoint(
      sessionId: 10,
      setId: secondExerciseSet,
      latitude: 51,
      longitude: 31,
      heading: 20,
    );
    await repository.addRoutePoint(
      sessionId: 10,
      setId: null,
      latitude: 52,
      longitude: 32,
      heading: 30,
    );

    final firstPoints = await repository.getRoutePoints(
      sessionId: 10,
      exerciseSessionId: 110,
    );
    final secondPoints = await repository.getRoutePoints(
      sessionId: 10,
      exerciseSessionId: 111,
    );

    expect(firstPoints.map((point) => point.latitude), [50]);
    expect(secondPoints.map((point) => point.latitude), [51]);
  });

  test('creates one UUIDv7 per row and preserves it through outbox transitions', () async {
    final firstId = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      workoutProgramExerciseId: 20,
      setNumber: 1,
      trackingMode: 'gps',
    );
    final secondId = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      workoutProgramExerciseId: 20,
      setNumber: 2,
      trackingMode: 'gps',
    );

    await repository.markSetAsFinishedLocally(firstId);
    await repository.markSetAsSyncing(firstId);
    await repository.markSetSyncFailed(firstId);
    await repository.markSetAsSyncing(firstId);

    final rows = await repository
        .watchActiveRunningSets(
          sessionId: 10,
          exerciseSessionId: 110,
          workoutProgramExerciseId: 20,
        )
        .first;
    final first = rows.singleWhere((row) => row.id == firstId);
    final second = rows.singleWhere((row) => row.id == secondId);

    expect(first.clientSetId, isNot(second.clientSetId));
    expect(first.clientSetId[14], '7');
    expect(second.clientSetId[14], '7');
    expect(first.exerciseSessionId, 110);
    expect(first.programExerciseId, 20);
    expect(first.syncStatus, 'syncing');
  });

  test('recovers interrupted syncing rows without changing client identity', () async {
    final setId = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    await repository.markSetAsFinishedLocally(setId);
    await repository.markSetAsSyncing(setId);
    final before = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;

    await repository.recoverInterruptedSetSyncs();

    final after = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;
    expect(after.single.clientSetId, before.single.clientSetId);
    expect(after.single.syncStatus, 'locallyCompleted');
  });

  test('reconciles a restored backend set by session, exercise session, and idempotency key', () async {
    final setId = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    await repository.markSetAsFinishedLocally(setId);
    await repository.markSetAsSyncing(setId);
    final before = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;

    await repository.reconcileSetAsSynced(
      sessionId: 10,
      exerciseSessionId: 110,
      clientSetId: before.single.clientSetId,
      remoteSetId: 901,
      durationSeconds: 0,
      distanceMeters: 0,
      speedKmH: 0,
    );

    final after = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;
    expect(after.single.syncStatus, 'synced');
    expect(after.single.remoteSetId, 901);
  });

  test('does not reconcile a restored set when its immutable metrics differ', () async {
    final setId = await repository.createNewActiveSet(
      sessionId: 10,
      exerciseSessionId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    await repository.markSetAsFinishedLocally(setId);
    final before = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;

    final reconciled = await repository.reconcileSetAsSynced(
      sessionId: 10,
      exerciseSessionId: 110,
      clientSetId: before.single.clientSetId,
      remoteSetId: 901,
      durationSeconds: 1,
      distanceMeters: 100,
      speedKmH: 10,
    );

    final after = await repository.watchActiveRunningSets(sessionId: 10, exerciseSessionId: 110).first;
    expect(reconciled, isFalse);
    expect(after.single.syncStatus, 'locallyCompleted');
    expect(after.single.remoteSetId, null);
  });
}
