// lib/core/database/database.dart
// ignore_for_file: comment_references

import 'package:drift/drift.dart';

// Generates the required boilerplate
part 'database.g.dart';

/// Table representing lap/set instances for the active running exercise.
///
/// Each row is one lap. Metrics are null until tracking data arrives.
/// The [isBusy] flag marks the currently active in-progress lap.
/// The [isDone] flag marks completed laps that have been sent to the backend.
extension ActiveRunningSetX on ActiveRunningSet {
  bool get readyToSync => !isBusy && !isDone;
}

class ActiveRunningSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(
    WorkoutSessionCache,
    #remoteSessionId,
    onDelete: KeyAction.cascade,
  )();
  IntColumn get programExerciseId => integer()(); // Links to ProgramExerciseEntity.id
  IntColumn get setNumber => integer()();

  // Real-time tracking metrics (null until tracked)
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get avgSpeedKmH => real().nullable()();
  RealColumn get currentSpeedKmH => real().nullable()();
  RealColumn get avgPaceMinKm => real().nullable()();
  RealColumn get currentPaceMinKm => real().nullable()();
  IntColumn get stepCount => integer().nullable()();

  // State flags
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  BoolColumn get isBusy => boolean().withDefault(const Constant(false))();

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
}

/// GPS route points collected during a running session.
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );

  // ── Existing methods ──────────────────────────────────────────────────────

  Stream<List<ActiveRunningSet>> watchSetsForSession(int sessionId) {
    return (select(activeRunningSets)..where((t) => t.sessionId.equals(sessionId))).watch();
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
      const ActiveRunningSetsCompanion(
        isDone: Value(false),
        isBusy: Value(false),
      ),
    );
  }

  Future<void> markSetAsDone(int setId) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      const ActiveRunningSetsCompanion(
        isDone: Value(true),
        isBusy: Value(false),
      ),
    );
  }

  Future<void> createNewActiveSet({
    required int sessionId,
    required int programExerciseId,
    required int setNumber,
    String? trackingMode,
  }) {
    return into(activeRunningSets).insert(
      ActiveRunningSetsCompanion.insert(
        sessionId: sessionId,
        programExerciseId: programExerciseId,
        setNumber: setNumber,
        isBusy: const Value(true),
        trackingMode: Value(trackingMode),
      ),
    );
  }

  // ── Running-specific methods ──────────────────────────────────────────────

  /// Returns the currently in-progress lap for [sessionId] (isBusy=true,
  /// isDone=false), or null if no lap is active.
  ///
  /// Used during session restore to recover the last unfinished lap.
  Future<ActiveRunningSet?> getInProgressLap(int sessionId) {
    return (select(activeRunningSets)
          ..where((t) => t.sessionId.equals(sessionId) & t.isBusy.equals(true) & t.isDone.equals(false))
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

  /// Returns all completed laps ([isDone]=true) for a given [sessionId],
  /// ordered by [setNumber] ascending.
  Future<List<ActiveRunningSet>> getCompletedLapsForSession(int sessionId) {
    return (select(activeRunningSets)
          ..where((t) => t.sessionId.equals(sessionId) & t.isDone.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }
}
