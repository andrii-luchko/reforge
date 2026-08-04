import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';

void main() {
  late WorkoutDatabase database;
  late WorkoutSessionCacheRepository repository;

  setUp(() {
    database = WorkoutDatabase(NativeDatabase.memory());
    repository = WorkoutSessionCacheRepositoryImpl(database);
  });

  tearDown(() => database.close());

  test('persists an ad-hoc plan, exercise identity, and dirty notes', () async {
    await repository.saveActiveSession(
      remoteSessionId: 182,
      source: CachedWorkoutSource.adHoc,
      executionPlanJson: '{"source":"adHoc","exercises":[]}',
    );
    await repository.saveExerciseSession(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
      exerciseId: 4,
      effectiveExerciseId: 4,
      exerciseSessionId: 246,
      position: 0,
    );
    await repository.saveExerciseNotesLocally(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
      notes: 'rainy intervals',
    );
    await repository.saveExerciseSession(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
      exerciseId: 4,
      effectiveExerciseId: 4,
      exerciseSessionId: 246,
      position: 0,
      notes: 'stale server note',
    );

    final workout = await repository.getActiveSession();
    final exercise = await repository.getExerciseSession(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
    );

    expect(workout?.programDayId, isNull);
    expect(workout?.workoutSource, CachedWorkoutSource.adHoc);
    expect(exercise?.exerciseSessionId, 246);
    expect(exercise?.notes, 'rainy intervals');
    expect(exercise?.noteStatus, CachedNotesSyncStatus.dirty);

    await repository.markExerciseNotesSynced(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
    );
    final synced = await repository.getExerciseSession(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
    );
    expect(synced?.noteStatus, CachedNotesSyncStatus.synced);
  });

  test('clearing the workout cascades to exercise cache and running outbox', () async {
    await database.customStatement('PRAGMA foreign_keys = ON;');
    await repository.saveActiveSession(
      remoteSessionId: 182,
      source: CachedWorkoutSource.adHoc,
    );
    await repository.saveExerciseSession(
      workoutSessionId: 182,
      executionKey: 'free-run:one',
      exerciseId: 4,
      effectiveExerciseId: 4,
      exerciseSessionId: 246,
      position: 0,
    );
    await database
        .into(database.activeRunningSets)
        .insert(
          ActiveRunningSetsCompanion.insert(
            sessionId: 182,
            exerciseSessionId: const Value(246),
            clientSetId: '019893a2-7078-76f9-8e8f-bf8e3b16bf93',
            setNumber: 1,
          ),
        );

    await repository.clearActiveSession();

    expect(await database.select(database.workoutExerciseSessionCache).get(), isEmpty);
    expect(await database.select(database.activeRunningSets).get(), isEmpty);
  });
}
