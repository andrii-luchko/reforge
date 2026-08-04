import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:reforge/core/database/database.dart';

enum CachedWorkoutSource {
  program,
  adHoc;

  static CachedWorkoutSource fromDatabase(String value) {
    return CachedWorkoutSource.values.firstWhere(
      (source) => source.name == value,
      orElse: () => CachedWorkoutSource.program,
    );
  }
}

enum WorkoutInitializationPhase { workoutCreated, exerciseSessionCreated, active }

enum CachedNotesSyncStatus { synced, dirty, syncing, failed }

extension WorkoutSessionCacheDataX on WorkoutSessionCacheData {
  CachedWorkoutSource get workoutSource => CachedWorkoutSource.fromDatabase(source);
}

extension WorkoutExerciseSessionCacheDataX on WorkoutExerciseSessionCacheData {
  CachedNotesSyncStatus get noteStatus => CachedNotesSyncStatus.values.firstWhere(
    (status) => status.name == notesSyncStatus,
    orElse: () => CachedNotesSyncStatus.dirty,
  );
}

/// Local persistence for the single workout currently owned by the client.
abstract interface class WorkoutSessionCacheRepository {
  Future<void> saveActiveSession({
    required int remoteSessionId,
    int? programDayId,
    CachedWorkoutSource source = CachedWorkoutSource.program,
    String? executionPlanJson,
    WorkoutInitializationPhase initializationPhase = WorkoutInitializationPhase.workoutCreated,
  });

  Future<WorkoutSessionCacheData?> getActiveSession();

  Future<void> updateInitializationPhase(WorkoutInitializationPhase phase);

  Future<void> saveExerciseSession({
    required int workoutSessionId,
    required String executionKey,
    required int exerciseId,
    required int effectiveExerciseId,
    required int exerciseSessionId,
    required int position,
    int? workoutProgramExerciseId,
    String notes = '',
  });

  Future<List<WorkoutExerciseSessionCacheData>> getExerciseSessions(int workoutSessionId);

  Future<WorkoutExerciseSessionCacheData?> getExerciseSession({
    required int workoutSessionId,
    required String executionKey,
  });

  Future<void> saveExerciseNotesLocally({
    required int workoutSessionId,
    required String executionKey,
    required String notes,
  });

  Future<void> markExerciseNotesSynced({
    required int workoutSessionId,
    required String executionKey,
  });

  Future<void> updateDuration(int durationSec);

  Future<void> updateLastExerciseIndex(int index);

  Future<void> clearActiveSession();
}

@LazySingleton(as: WorkoutSessionCacheRepository)
class WorkoutSessionCacheRepositoryImpl implements WorkoutSessionCacheRepository {
  WorkoutSessionCacheRepositoryImpl(this._db);

  final WorkoutDatabase _db;

  @override
  Future<void> saveActiveSession({
    required int remoteSessionId,
    int? programDayId,
    CachedWorkoutSource source = CachedWorkoutSource.program,
    String? executionPlanJson,
    WorkoutInitializationPhase initializationPhase = WorkoutInitializationPhase.workoutCreated,
  }) async {
    await _db.transaction(() async {
      await _db.delete(_db.workoutSessionCache).go();
      await _db
          .into(_db.workoutSessionCache)
          .insert(
            WorkoutSessionCacheCompanion.insert(
              remoteSessionId: remoteSessionId,
              programDayId: Value(programDayId),
              source: Value(source.name),
              executionPlanJson: Value(executionPlanJson),
              initializationPhase: Value(initializationPhase.name),
              startedAt: DateTime.now(),
            ),
          );
    });
  }

  @override
  Future<WorkoutSessionCacheData?> getActiveSession() {
    return (_db.select(_db.workoutSessionCache)..limit(1)).getSingleOrNull();
  }

  @override
  Future<void> updateInitializationPhase(WorkoutInitializationPhase phase) async {
    final existing = await getActiveSession();
    if (existing == null) return;
    await (_db.update(_db.workoutSessionCache)..where((table) => table.id.equals(existing.id))).write(
      WorkoutSessionCacheCompanion(
        initializationPhase: Value(phase.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> saveExerciseSession({
    required int workoutSessionId,
    required String executionKey,
    required int exerciseId,
    required int effectiveExerciseId,
    required int exerciseSessionId,
    required int position,
    int? workoutProgramExerciseId,
    String notes = '',
  }) async {
    await _db.transaction(() async {
      final existing = await getExerciseSession(
        workoutSessionId: workoutSessionId,
        executionKey: executionKey,
      );
      final preserveLocalNotes = existing != null && existing.noteStatus != CachedNotesSyncStatus.synced;
      final companion = WorkoutExerciseSessionCacheCompanion(
        workoutSessionId: Value(workoutSessionId),
        executionKey: Value(executionKey),
        exerciseId: Value(exerciseId),
        effectiveExerciseId: Value(effectiveExerciseId),
        exerciseSessionId: Value(exerciseSessionId),
        workoutProgramExerciseId: Value(workoutProgramExerciseId),
        position: Value(position),
        notes: Value(preserveLocalNotes ? existing.notes : notes),
        notesSyncStatus: Value(
          preserveLocalNotes ? existing.notesSyncStatus : CachedNotesSyncStatus.synced.name,
        ),
        updatedAt: Value(DateTime.now()),
      );
      if (existing == null) {
        await _db.into(_db.workoutExerciseSessionCache).insert(companion);
      } else {
        await (_db.update(_db.workoutExerciseSessionCache)..where((table) => table.id.equals(existing.id))).write(
          companion,
        );
      }
    });
  }

  @override
  Future<List<WorkoutExerciseSessionCacheData>> getExerciseSessions(int workoutSessionId) {
    return (_db.select(_db.workoutExerciseSessionCache)
          ..where((table) => table.workoutSessionId.equals(workoutSessionId))
          ..orderBy([(table) => OrderingTerm.asc(table.position)]))
        .get();
  }

  @override
  Future<WorkoutExerciseSessionCacheData?> getExerciseSession({
    required int workoutSessionId,
    required String executionKey,
  }) {
    return (_db.select(_db.workoutExerciseSessionCache)
          ..where(
            (table) => table.workoutSessionId.equals(workoutSessionId) & table.executionKey.equals(executionKey),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  @override
  Future<void> saveExerciseNotesLocally({
    required int workoutSessionId,
    required String executionKey,
    required String notes,
  }) {
    return (_db.update(_db.workoutExerciseSessionCache)..where(
          (table) => table.workoutSessionId.equals(workoutSessionId) & table.executionKey.equals(executionKey),
        ))
        .write(
          WorkoutExerciseSessionCacheCompanion(
            notes: Value(notes),
            notesSyncStatus: Value(CachedNotesSyncStatus.dirty.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> markExerciseNotesSynced({
    required int workoutSessionId,
    required String executionKey,
  }) {
    return (_db.update(_db.workoutExerciseSessionCache)..where(
          (table) => table.workoutSessionId.equals(workoutSessionId) & table.executionKey.equals(executionKey),
        ))
        .write(
          WorkoutExerciseSessionCacheCompanion(
            notesSyncStatus: Value(CachedNotesSyncStatus.synced.name),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<void> updateDuration(int durationSec) async {
    final existing = await getActiveSession();
    if (existing == null) return;
    await (_db.update(_db.workoutSessionCache)..where((table) => table.id.equals(existing.id))).write(
      WorkoutSessionCacheCompanion(
        durationSec: Value(durationSec),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> updateLastExerciseIndex(int index) async {
    final existing = await getActiveSession();
    if (existing == null) return;
    await (_db.update(_db.workoutSessionCache)..where((table) => table.id.equals(existing.id))).write(
      WorkoutSessionCacheCompanion(
        lastExerciseIndex: Value(index),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> clearActiveSession() {
    return _db.delete(_db.workoutSessionCache).go();
  }
}
