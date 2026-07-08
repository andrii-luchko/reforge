import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'package:reforge/core/database/database.dart';

/// Abstraction for local persistence of the currently active workout session.
/// At most one record is kept in the [WorkoutSessionCache] table at a time.
abstract interface class WorkoutSessionCacheRepository {
  /// Persists a newly started session. Replaces any previously cached entry.
  Future<void> saveActiveSession({
    required int remoteSessionId,
    required int programDayId,
  });

  /// Returns the cached session, or null if no active session is stored.
  Future<WorkoutSessionCacheData?> getActiveSession();

  /// Updates the stored duration so we don't lose it on force-kill.
  Future<void> updateDuration(int durationSec);

  /// Updates the last known exercise index for navigation fallback.
  Future<void> updateLastExerciseIndex(int index);

  /// Removes the cached session entry. Call after successful end or cancel.
  Future<void> clearActiveSession();
}

@LazySingleton(as: WorkoutSessionCacheRepository)
class WorkoutSessionCacheRepositoryImpl implements WorkoutSessionCacheRepository {
  WorkoutSessionCacheRepositoryImpl(this._db);

  final WorkoutDatabase _db;

  @override
  Future<void> saveActiveSession({
    required int remoteSessionId,
    required int programDayId,
  }) async {
    // Always keep a single row — delete any existing entry first.
    await _db.delete(_db.workoutSessionCache).go();

    await _db
        .into(_db.workoutSessionCache)
        .insert(
          WorkoutSessionCacheCompanion.insert(
            remoteSessionId: remoteSessionId,
            programDayId: programDayId,
            startedAt: DateTime.now(),
          ),
        );
  }

  @override
  Future<WorkoutSessionCacheData?> getActiveSession() {
    return (_db.select(_db.workoutSessionCache)..limit(1)).getSingleOrNull();
  }

  @override
  Future<void> updateDuration(int durationSec) async {
    final existing = await getActiveSession();
    if (existing == null) return;

    await (_db.update(
      _db.workoutSessionCache,
    )..where((t) => t.id.equals(existing.id))).write(WorkoutSessionCacheCompanion(durationSec: Value(durationSec)));
  }

  @override
  Future<void> updateLastExerciseIndex(int index) async {
    final existing = await getActiveSession();
    if (existing == null) return;

    await (_db.update(
      _db.workoutSessionCache,
    )..where((t) => t.id.equals(existing.id))).write(WorkoutSessionCacheCompanion(lastExerciseIndex: Value(index)));
  }

  @override
  Future<void> clearActiveSession() {
    return _db.delete(_db.workoutSessionCache).go();
  }
}
