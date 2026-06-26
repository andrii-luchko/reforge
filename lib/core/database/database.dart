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

@DriftDatabase(tables: [ActiveSessions, ActiveRunningSets])
class WorkoutDatabase extends _$WorkoutDatabase {
  WorkoutDatabase(super.e);

  @override
  int get schemaVersion => 1;

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
