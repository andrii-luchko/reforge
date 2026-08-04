// lib/core/database/database.dart
// ignore_for_file: comment_references

import 'package:drift/drift.dart';
import 'package:reforge/features/running/domain/enums/running_set_sync_status.dart';
import 'package:uuid/uuid.dart';

// Generates the required boilerplate
part 'database.g.dart';

/// Table representing lap/set instances for the active running exercise.
///
/// Each row is one lap. Metrics are null until tracking data arrives.
extension ActiveRunningSetX on ActiveRunningSet {
  RunningSetSyncStatus get outboxStatus => RunningSetSyncStatus.fromDatabase(syncStatus);

  bool get isTracking => outboxStatus == RunningSetSyncStatus.tracking;
  bool get isLocallyCompleted => outboxStatus == RunningSetSyncStatus.locallyCompleted;
  bool get isSyncing => outboxStatus == RunningSetSyncStatus.syncing;
  bool get hasSyncFailed => outboxStatus == RunningSetSyncStatus.syncFailed;
  bool get isSynced => outboxStatus == RunningSetSyncStatus.synced;
  bool get isPendingSync => isLocallyCompleted || isSyncing || hasSyncFailed;
  bool get canStartSync => isLocallyCompleted || hasSyncFailed;
}

@TableIndex(name: 'idx_active_running_sets_search', columns: {#sessionId, #exerciseSessionId, #syncStatus})
@TableIndex(
  name: 'idx_active_running_sets_client_identity',
  columns: {#exerciseSessionId, #clientSetId},
  unique: true,
)
class ActiveRunningSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
    WorkoutSessionCache,
    #remoteSessionId,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get exerciseSessionId => integer().nullable()();
  IntColumn get programExerciseId => integer().nullable()();
  TextColumn get clientSetId => text()();
  IntColumn get remoteSetId => integer().nullable()();
  IntColumn get setNumber => integer()();

  // Real-time tracking metrics (null until tracked)
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get avgSpeedKmH => real().nullable()();
  RealColumn get currentSpeedKmH => real().nullable()();
  RealColumn get avgPaceMinKm => real().nullable()();
  RealColumn get currentPaceMinKm => real().nullable()();
  IntColumn get stepCount => integer().nullable()();

  TextColumn get syncStatus => text().withDefault(
    Constant(RunningSetSyncStatus.tracking.name),
  )();

  // ── Running-specific fields ──────────────────────────────────────────────

  /// Tracking mode used for this lap: 'gps' or 'pedometer'.
  TextColumn get trackingMode => text().nullable()();

  /// Segment type for future segment-based running (e.g. 'run', 'walk').
  /// Defaults to 'run'.
  TextColumn get segmentType => text().withDefault(const Constant('run'))();

  /// Links to ExerciseSegmentEntity.id for backend synchronization.
  IntColumn get programSegmentId => integer().nullable()();

  /// Timestamp of the last background snapshot written by the background
  /// service. Used to detect stale in-progress laps after a force-kill.
  DateTimeColumn get lastSnapshotAt => dateTime().nullable()();
}

/// Cache table for the currently active workout session.
/// Always contains at most ONE row — the session currently in progress.
/// Cleared on successful completion or cancellation.
class WorkoutSessionCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Remote session id from the backend (WorkoutSession.id)
  IntColumn get remoteSessionId => integer().unique()();

  /// Program day id needed to re-fetch ProgramDayEntity with full exercise details
  IntColumn get programDayId => integer()();

  /// When the session was originally started (for display purposes)
  DateTimeColumn get startedAt => dateTime()();

  /// Accumulated duration in seconds — updated periodically while workout is active.
  /// Stored here so duration is not lost on force-kill.
  IntColumn get durationSec => integer().withDefault(const Constant(0))();

  /// Index of the last exercise the user was on.
  /// Used as a fallback to navigate back to the right screen on restore.
  IntColumn get lastExerciseIndex => integer().withDefault(const Constant(0))();

  /// Last time this session had activity. Used for garbage collection.
  DateTimeColumn get updatedAt => dateTime().nullable()();
}

/// GPS route points collected during a running session.
@TableIndex(name: 'idx_session_route_points_lookup', columns: {#sessionId, #timestamp})
class SessionRoutePoints extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Links to the overall workout session.
  IntColumn get sessionId => integer().references(
    WorkoutSessionCache,
    #remoteSessionId,
    onDelete: KeyAction.cascade,
  )();

  /// Links to the specific active running set/lap.
  /// Nullable in case we log points before a set is properly assigned,
  /// though usually it will map to an ActiveRunningSets.id.
  IntColumn get setId => integer().nullable()();

  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get heading => real().nullable()();
  DateTimeColumn get timestamp => dateTime()();
}

@DriftDatabase(tables: [ActiveRunningSets, WorkoutSessionCache, SessionRoutePoints])
class WorkoutDatabase extends _$WorkoutDatabase {
  WorkoutDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(workoutSessionCache, workoutSessionCache.updatedAt);
        if (to < 3) await m.createIndex(idxActiveRunningSetsSearch);
        await m.createIndex(idxSessionRoutePointsLookup);
      }
      if (from < 3) {
        await customStatement('ALTER TABLE active_running_sets ADD COLUMN exercise_session_id INTEGER;');
        await customStatement('ALTER TABLE active_running_sets ADD COLUMN client_set_id TEXT;');
        await customStatement('ALTER TABLE active_running_sets ADD COLUMN remote_set_id INTEGER;');
        await customStatement(
          "ALTER TABLE active_running_sets ADD COLUMN sync_status TEXT NOT NULL DEFAULT 'tracking';",
        );

        final legacyRows = await customSelect(
          'SELECT id, is_done, is_busy FROM active_running_sets;',
        ).get();
        const uuid = Uuid();
        for (final row in legacyRows) {
          final status = row.read<bool>('is_done')
              ? RunningSetSyncStatus.synced
              : row.read<bool>('is_busy')
              ? RunningSetSyncStatus.tracking
              : RunningSetSyncStatus.locallyCompleted;
          await customStatement(
            'UPDATE active_running_sets SET client_set_id = ?, sync_status = ? WHERE id = ?;',
            [uuid.v7(), status.name, row.read<int>('id')],
          );
        }

        await customStatement('DROP INDEX IF EXISTS idx_active_running_sets_search;');
        await m.alterTable(TableMigration(activeRunningSets));
        await m.createIndex(idxActiveRunningSetsSearch);
        await m.createIndex(idxActiveRunningSetsClientIdentity);
      }
    },
  );

  // ── Existing methods ──────────────────────────────────────────────────────

  Stream<List<ActiveRunningSet>> watchSetsForExercise({
    required int sessionId,
    required int exerciseSessionId,
    int? programExerciseId,
  }) {
    return (select(activeRunningSets)..where(
          (t) =>
              t.sessionId.equals(sessionId) &
              (t.exerciseSessionId.equals(exerciseSessionId) |
                  (t.exerciseSessionId.isNull() &
                      (programExerciseId == null
                          ? const Constant(false)
                          : t.programExerciseId.equals(programExerciseId)))),
        ))
        .watch();
  }

  Future<void> updateActiveSetMetrics({
    required int setId,
    required double distance,
    required int duration,
    required double avgSpeedKmH,
    required double currentSpeedKmH,
    required double avgPaceMinKm,
    required double currentPaceMinKm,
    required int stepCount,
  }) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        distanceMeters: Value(distance),
        durationSeconds: Value(duration),
        avgSpeedKmH: Value(avgSpeedKmH),
        currentSpeedKmH: Value(currentSpeedKmH),
        avgPaceMinKm: Value(avgPaceMinKm),
        currentPaceMinKm: Value(currentPaceMinKm),
        stepCount: Value(stepCount),
      ),
    );
  }

  Future<void> markSetAsFinishedLocally(int setId) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        syncStatus: Value(RunningSetSyncStatus.locallyCompleted.name),
      ),
    );
  }

  Future<void> markSetAsSyncing(int setId) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        syncStatus: Value(RunningSetSyncStatus.syncing.name),
      ),
    );
  }

  Future<void> markSetSyncFailed(int setId) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        syncStatus: Value(RunningSetSyncStatus.syncFailed.name),
      ),
    );
  }

  Future<void> markSetAsSynced(int setId, {required int remoteSetId}) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        remoteSetId: Value(remoteSetId),
        syncStatus: Value(RunningSetSyncStatus.synced.name),
      ),
    );
  }

  Future<void> recoverInterruptedSetSyncs() {
    return (update(activeRunningSets)..where(
          (t) => t.syncStatus.equals(RunningSetSyncStatus.syncing.name),
        ))
        .write(
          ActiveRunningSetsCompanion(
            syncStatus: Value(RunningSetSyncStatus.locallyCompleted.name),
          ),
        );
  }

  // ── Running-specific methods ──────────────────────────────────────────────

  /// Returns the currently in-progress lap for one program exercise.
  Future<ActiveRunningSet?> getInProgressLapForExercise({
    required int sessionId,
    required int exerciseSessionId,
    int? programExerciseId,
  }) {
    return (select(activeRunningSets)
          ..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                (t.exerciseSessionId.equals(exerciseSessionId) |
                    (t.exerciseSessionId.isNull() &
                        (programExerciseId == null
                            ? const Constant(false)
                            : t.programExerciseId.equals(programExerciseId)))) &
                t.syncStatus.equals(RunningSetSyncStatus.tracking.name),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns any in-progress lap for session-level restore discovery.
  Future<ActiveRunningSet?> getAnyInProgressLapForSession(int sessionId) {
    return (select(activeRunningSets)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.syncStatus.equals(RunningSetSyncStatus.tracking.name),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns the last lap (highest setNumber) for one program exercise.
  Future<ActiveRunningSet?> getLastLap({
    required int sessionId,
    required int exerciseSessionId,
    int? programExerciseId,
  }) {
    return (select(activeRunningSets)
          ..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                (t.exerciseSessionId.equals(exerciseSessionId) |
                    (t.exerciseSessionId.isNull() &
                        (programExerciseId == null
                            ? const Constant(false)
                            : t.programExerciseId.equals(programExerciseId)))),
          )
          ..orderBy([(t) => OrderingTerm(expression: t.setNumber, mode: OrderingMode.desc)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Writes a periodic snapshot of the current lap metrics.
  ///
  /// Called every ~5 seconds by the background tracking service so that
  /// metrics survive a force-kill. The [lastSnapshotAt] timestamp is updated
  /// so callers can detect stale snapshots.
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
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        distanceMeters: Value(distance),
        durationSeconds: Value(duration),
        avgSpeedKmH: Value(avgSpeedKmH),
        currentSpeedKmH: Value(currentSpeedKmH),
        avgPaceMinKm: Value(avgPaceMinKm),
        currentPaceMinKm: Value(currentPaceMinKm),
        stepCount: Value(stepCount),
        lastSnapshotAt: Value(DateTime.now()),
      ),
    );
  }

  /// Returns completed laps for one program exercise, ordered by set number.
  Future<List<ActiveRunningSet>> getCompletedLapsForExercise({
    required int sessionId,
    required int exerciseSessionId,
    int? programExerciseId,
  }) {
    return (select(activeRunningSets)
          ..where(
            (t) =>
                t.sessionId.equals(sessionId) &
                (t.exerciseSessionId.equals(exerciseSessionId) |
                    (t.exerciseSessionId.isNull() &
                        (programExerciseId == null
                            ? const Constant(false)
                            : t.programExerciseId.equals(programExerciseId)))) &
                t.syncStatus.equals(RunningSetSyncStatus.synced.name),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }
}
