// lib/core/database/database.dart
import 'package:drift/drift.dart';

// Generates the required boilerplate
part 'database.g.dart';

/// Table representing the active overarching workout session
class ActiveSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get programDayId => integer()(); // Links to your ProgramDayEntity.id
  TextColumn get status => text()(); // e.g., 'running', 'paused'
  DateTimeColumn get startTime => dateTime()();
}

/// Table representing your instances for the active run
class ActiveRunningSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().references(ActiveSessions, #id)();
  IntColumn get programExerciseId => integer()(); // Links to ProgramExerciseEntity.id
  IntColumn get setNumber => integer()();

  // Real-time tracking metrics (Null until tracked)
  RealColumn get distanceMeters => real().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  RealColumn get paceKmH => real().nullable()();

  // State flags
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  BoolColumn get isBusy => boolean().withDefault(const Constant(false))();
}

/// Cache table for the currently active workout session.
/// Always contains at most ONE row — the session currently in progress.
/// Cleared on successful completion or cancellation.
class WorkoutSessionCache extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Remote session id from the backend (WorkoutSession.id)
  IntColumn get remoteSessionId => integer()();

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

@DriftDatabase(tables: [ActiveSessions, ActiveRunningSets, WorkoutSessionCache])
class WorkoutDatabase extends _$WorkoutDatabase {
  WorkoutDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(workoutSessionCache);
          }
        },
      );

  Stream<List<ActiveRunningSet>> watchSetsForSession(int sessionId) {
    return (select(activeRunningSets)..where((t) => t.sessionId.equals(sessionId))).watch();
  }

  Future<void> updateActiveSetMetrics({
    required int setId,
    required double distance,
    required int duration,
    required double pace,
  }) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      ActiveRunningSetsCompanion(
        distanceMeters: Value(distance),
        durationSeconds: Value(duration),
        paceKmH: Value(pace),
      ),
    );
  }

  Future<void> markSetAsDone(int setId) {
    return (update(activeRunningSets)..where((t) => t.id.equals(setId))).write(
      const ActiveRunningSetsCompanion(
        isDone: Value(true),
      ),
    );
  }

  Future<void> createNewActiveSet({
    required int sessionId,
    required int programExerciseId,
    required int setNumber,
  }) {
    return into(activeRunningSets).insert(
      ActiveRunningSetsCompanion.insert(
        sessionId: sessionId,
        programExerciseId: programExerciseId,
        setNumber: setNumber,
      ),
    );
  }
}
