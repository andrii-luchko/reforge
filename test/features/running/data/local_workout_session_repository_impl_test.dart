import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/data/repositories/local_workout_session_repository_impl.dart';

void main() {
  late WorkoutDatabase database;
  late LocalWorkoutSessionRepositoryImpl repository;

  setUp(() async {
    database = WorkoutDatabase(NativeDatabase.memory());
    repository = LocalWorkoutSessionRepositoryImpl(database);
    await database
        .into(database.workoutSessionCache)
        .insert(
          WorkoutSessionCacheCompanion.insert(
            remoteSessionId: 10,
            programDayId: 30,
            startedAt: DateTime(2026),
          ),
        );
  });

  tearDown(() => database.close());

  test('scopes watched, active, last, and completed laps by program exercise', () async {
    final firstExerciseLap1 = await repository.createNewActiveSet(
      sessionId: 10,
      programExerciseId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    final firstExerciseLap2 = await repository.createNewActiveSet(
      sessionId: 10,
      programExerciseId: 110,
      setNumber: 2,
      trackingMode: 'gps',
    );
    final secondExerciseLap1 = await repository.createNewActiveSet(
      sessionId: 10,
      programExerciseId: 111,
      setNumber: 1,
      trackingMode: 'pedometer',
    );

    final firstRows = await repository.watchActiveRunningSets(sessionId: 10, programExerciseId: 110).first;
    final secondRows = await repository.watchActiveRunningSets(sessionId: 10, programExerciseId: 111).first;

    expect(firstRows.map((row) => row.id), [firstExerciseLap1, firstExerciseLap2]);
    expect(secondRows.map((row) => row.id), [secondExerciseLap1]);
    expect(
      (await repository.getLastLap(sessionId: 10, programExerciseId: 110))?.setNumber,
      2,
    );
    expect(
      (await repository.getLastLap(sessionId: 10, programExerciseId: 111))?.setNumber,
      1,
    );

    await repository.markSetAsDone(firstExerciseLap1);
    final completed = await database.getCompletedLapsForExercise(
      sessionId: 10,
      programExerciseId: 110,
    );
    expect(completed.map((row) => row.id), [firstExerciseLap1]);
  });

  test('returns route points only for the requested program exercise', () async {
    final firstExerciseSet = await repository.createNewActiveSet(
      sessionId: 10,
      programExerciseId: 110,
      setNumber: 1,
      trackingMode: 'gps',
    );
    final secondExerciseSet = await repository.createNewActiveSet(
      sessionId: 10,
      programExerciseId: 111,
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
      programExerciseId: 110,
    );
    final secondPoints = await repository.getRoutePoints(
      sessionId: 10,
      programExerciseId: 111,
    );

    expect(firstPoints.map((point) => point.latitude), [50]);
    expect(secondPoints.map((point) => point.latitude), [51]);
  });
}
