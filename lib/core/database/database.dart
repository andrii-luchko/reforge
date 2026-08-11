// lib/core/database/database.dart
// ignore_for_file: comment_references

import 'package:drift/drift.dart';
import 'package:reforge/features/running/domain/enums/running_milestone_candidate_status.dart';
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

  /// Tracking mode used for this lap: 'gps', 'treadmill', or legacy 'pedometer'.
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

@TableIndex(
  name: 'idx_running_milestone_candidates_identity',
  columns: {#runningSetId, #milestoneKey},
  unique: true,
)
@TableIndex(
  name: 'idx_running_milestone_candidates_pending',
  columns: {#workoutSessionId, #status},
)
class RunningMilestoneCandidates extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runningSetId => integer().references(
    ActiveRunningSets,
    #id,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get exerciseId => integer()();
  IntColumn get workoutSessionId => integer()();
  IntColumn get exerciseSessionId => integer()();
  IntColumn get durationSec => integer()();
  RealColumn get distanceM => real()();
  TextColumn get milestoneKey => text()();
  TextColumn get status => text().withDefault(
    Constant(RunningMilestoneCandidateStatus.pending.name),
  )();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get attemptedAt => dateTime().nullable()();
}

/// Cache table for the currently active workout session.
/// Always contains at most ONE row — the session currently in progress.
/// Cleared on successful completion or cancellation.
class WorkoutSessionCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Remote session id from the backend (WorkoutSession.id)
  IntColumn get remoteSessionId => integer().unique()();

  /// Program day id needed to re-fetch ProgramDayEntity with full exercise details
  IntColumn get programDayId => integer().nullable()();

  /// `program` for scheduled workouts, `adHoc` for workouts assembled at runtime.
  TextColumn get source => text().withDefault(const Constant('program'))();

  /// Minimal serialized execution plan used when no program day exists.
  TextColumn get executionPlanJson => text().nullable()();

  /// Last durable initialization boundary reached by the client.
  TextColumn get initializationPhase => text().withDefault(const Constant('workoutCreated'))();

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

@TableIndex(
  name: 'idx_workout_exercise_session_cache_identity',
  columns: {#workoutSessionId, #executionKey},
  unique: true,
)
@TableIndex(
  name: 'idx_workout_exercise_session_cache_remote',
  columns: {#exerciseSessionId},
  unique: true,
)
class WorkoutExerciseSessionCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get workoutSessionId => integer().references(
    WorkoutSessionCache,
    #remoteSessionId,
    onDelete: KeyAction.cascade,
  )();

  TextColumn get executionKey => text()();
  IntColumn get exerciseId => integer()();
  IntColumn get effectiveExerciseId => integer()();
  IntColumn get exerciseSessionId => integer().nullable()();
  IntColumn get workoutProgramExerciseId => integer().nullable()();
  IntColumn get position => integer()();
  TextColumn get notes => text().withDefault(const Constant(''))();
  TextColumn get notesSyncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime()();
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

@DriftDatabase(
  tables: [
    ActiveRunningSets,
    RunningMilestoneCandidates,
    WorkoutSessionCache,
    WorkoutExerciseSessionCache,
    SessionRoutePoints,
  ],
)
class WorkoutDatabase extends _$WorkoutDatabase {
  WorkoutDatabase(super.e);

  @override
  int get schemaVersion => 5;

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
      if (from < 4) {
        await customStatement(
          "ALTER TABLE workout_session_cache ADD COLUMN source TEXT NOT NULL DEFAULT 'program';",
        );
        await customStatement(
          'ALTER TABLE workout_session_cache ADD COLUMN execution_plan_json TEXT;',
        );
        await customStatement(
          "ALTER TABLE workout_session_cache ADD COLUMN initialization_phase TEXT NOT NULL DEFAULT 'workoutCreated';",
        );
        await m.alterTable(TableMigration(workoutSessionCache));
        await m.createTable(workoutExerciseSessionCache);
        await m.createIndex(idxWorkoutExerciseSessionCacheIdentity);
        await m.createIndex(idxWorkoutExerciseSessionCacheRemote);
      }
      if (from < 5) {
        await m.createTable(runningMilestoneCandidates);
        await m.createIndex(idxRunningMilestoneCandidatesIdentity);
        await m.createIndex(idxRunningMilestoneCandidatesPending);
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

  Future<bool> reconcileSetAsSynced({
    required int sessionId,
    required int exerciseSessionId,
    required String clientSetId,
    required int remoteSetId,
    required int durationSeconds,
    required double distanceMeters,
    required double speedKmH,
    int? programSegmentId,
  }) async {
    final row =
        await (select(activeRunningSets)..where(
              (t) =>
                  t.sessionId.equals(sessionId) &
                  t.exerciseSessionId.equals(exerciseSessionId) &
                  t.clientSetId.equals(clientSetId),
            ))
            .getSingleOrNull();
    if (row == null ||
        (row.durationSeconds ?? 0) != durationSeconds ||
        !_sameMetric(row.distanceMeters ?? 0, distanceMeters) ||
        !_sameMetric(row.avgSpeedKmH ?? 0, speedKmH) ||
        row.programSegmentId != programSegmentId) {
      return false;
    }

    await (update(activeRunningSets)..where((t) => t.id.equals(row.id))).write(
      ActiveRunningSetsCompanion(
        remoteSetId: Value(remoteSetId),
        syncStatus: Value(RunningSetSyncStatus.synced.name),
      ),
    );
    return true;
  }

  bool _sameMetric(double actual, double expected) => (actual - expected).abs() <= 0.000001;

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
