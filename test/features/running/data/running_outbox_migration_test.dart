import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/core/database/database.dart';
import 'package:sqlite3/sqlite3.dart';

void main() {
  test('creates running milestone candidates when upgrading from schema v4', () async {
    final sqlite = sqlite3.openInMemory()..execute('PRAGMA user_version = 4;');
    final database = WorkoutDatabase(NativeDatabase.opened(sqlite));
    addTearDown(database.close);

    final columns = await database.customSelect('PRAGMA table_info(running_milestone_candidates);').get();

    expect(columns, isNotEmpty);
    expect(
      columns.map((row) => row.read<String>('name')),
      containsAll(['running_set_id', 'milestone_key', 'distance_m', 'duration_sec', 'status']),
    );
  });

  test('migrates v2 running rows to durable outbox identities without data loss', () async {
    final sqlite = sqlite3.openInMemory()
      ..execute('''
        CREATE TABLE workout_session_cache (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          remote_session_id INTEGER NOT NULL UNIQUE,
          program_day_id INTEGER NOT NULL,
          started_at INTEGER NOT NULL,
          duration_sec INTEGER NOT NULL DEFAULT 0,
          last_exercise_index INTEGER NOT NULL DEFAULT 0,
          updated_at INTEGER
        );
      ''')
      ..execute('''
        CREATE TABLE active_running_sets (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER NOT NULL REFERENCES workout_session_cache(remote_session_id) ON DELETE CASCADE,
          program_exercise_id INTEGER NOT NULL,
          set_number INTEGER NOT NULL,
          distance_meters REAL,
          duration_seconds INTEGER,
          avg_speed_km_h REAL,
          current_speed_km_h REAL,
          avg_pace_min_km REAL,
          current_pace_min_km REAL,
          step_count INTEGER,
          is_done INTEGER NOT NULL DEFAULT 0 CHECK (is_done IN (0, 1)),
          is_busy INTEGER NOT NULL DEFAULT 0 CHECK (is_busy IN (0, 1)),
          tracking_mode TEXT,
          segment_type TEXT NOT NULL DEFAULT 'run',
          program_segment_id INTEGER,
          last_snapshot_at INTEGER
        );
      ''')
      ..execute(
        'CREATE INDEX idx_active_running_sets_search '
        'ON active_running_sets(session_id, is_busy, is_done);',
      )
      ..execute('''
        CREATE TABLE session_route_points (
          id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
          session_id INTEGER NOT NULL REFERENCES workout_session_cache(remote_session_id) ON DELETE CASCADE,
          set_id INTEGER,
          latitude REAL NOT NULL,
          longitude REAL NOT NULL,
          heading REAL,
          timestamp INTEGER NOT NULL
        );
      ''')
      ..execute(
        'CREATE INDEX idx_session_route_points_lookup '
        'ON session_route_points(session_id, timestamp);',
      )
      ..execute(
        'INSERT INTO workout_session_cache '
        '(remote_session_id, program_day_id, started_at) VALUES (10, 30, 0);',
      )
      ..execute('''
        INSERT INTO active_running_sets
          (session_id, program_exercise_id, set_number, distance_meters, is_done, is_busy)
        VALUES
          (10, 20, 1, 1000, 0, 1),
          (10, 20, 2, 1500, 0, 0),
          (10, 20, 3, 2000, 1, 0);
      ''')
      ..execute('PRAGMA user_version = 2;');

    final database = WorkoutDatabase(NativeDatabase.opened(sqlite));
    addTearDown(database.close);

    final rows = await database.select(database.activeRunningSets).get();

    expect(rows, hasLength(3));
    expect(rows.map((row) => row.distanceMeters), [1000, 1500, 2000]);
    expect(rows.map((row) => row.syncStatus), ['tracking', 'locallyCompleted', 'synced']);
    expect(rows.map((row) => row.clientSetId).toSet(), hasLength(3));
    expect(rows.map((row) => row.clientSetId[14]), everyElement('7'));
    expect(rows.map((row) => row.exerciseSessionId), everyElement(isNull));
    expect(rows.map((row) => row.programExerciseId), everyElement(20));

    final columns = await database.customSelect('PRAGMA table_info(active_running_sets);').get();
    final byName = {for (final row in columns) row.read<String>('name'): row};
    expect(byName, isNot(contains('is_done')));
    expect(byName, isNot(contains('is_busy')));
    expect(byName['client_set_id']!.read<int>('notnull'), 1);
    expect(byName['program_exercise_id']!.read<int>('notnull'), 0);

    final workoutColumns = await database.customSelect('PRAGMA table_info(workout_session_cache);').get();
    final workoutByName = {
      for (final row in workoutColumns) row.read<String>('name'): row,
    };
    expect(workoutByName['program_day_id']!.read<int>('notnull'), 0);
    expect(workoutByName, contains('source'));
    expect(workoutByName, contains('execution_plan_json'));
    expect(workoutByName, contains('initialization_phase'));

    final cachedWorkout = await database.select(database.workoutSessionCache).getSingle();
    expect(cachedWorkout.programDayId, 30);
    expect(cachedWorkout.source, 'program');
    expect(cachedWorkout.initializationPhase, 'workoutCreated');

    final exerciseCacheColumns = await database
        .customSelect(
          'PRAGMA table_info(workout_exercise_session_cache);',
        )
        .get();
    expect(exerciseCacheColumns, isNotEmpty);
  });
}
