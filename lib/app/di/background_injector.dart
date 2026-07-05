import 'dart:io';

import 'package:drift/native.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/running/data/repositories/local_workout_session_repository_impl.dart';
import 'package:reforge/features/running/data/services/audio_feedback_service.dart';
import 'package:reforge/features/running/data/services/gps_tracking_engine.dart';
import 'package:reforge/features/running/data/services/pedometer_tracking_engine.dart';
import 'package:reforge/features/running/data/services/running_tracking_manager.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// A minimal, self-contained GetIt container for the background isolate.
///
/// The background isolate starts with a completely empty Dart VM — it does
/// NOT inherit the main isolate's [GetIt] instance, Firebase, RevenueCat,
/// or any other UI-layer dependency. We only register what the running tracker
/// actually needs:
///
///   [WorkoutDatabase] → [LocalWorkoutSessionRepository]
///         ↓
///   [GpsTrackingEngine]  [PedometerTrackingEngine]
///         ↓                      ↓
///              [RunningSessionManager]
///
/// Call [configureBackgroundDependencies] once at the start of [onStart].
final GetIt backgroundGetIt = GetIt.instance;

/// Registers the minimal dependency graph for the background tracking isolate.
///
/// Safe to call multiple times — [GetIt] will skip already-registered types.
Future<void> configureBackgroundDependencies() async {
  if (backgroundGetIt.isRegistered<WorkoutDatabase>()) return;

  // ── Database ───────────────────────────────────────────────────────────────
  // We intentionally use NativeDatabase directly (not driftDatabase()) for two
  // reasons:
  //
  // 1. On Android, flutter_background_service runs in a SEPARATE PROCESS from
  //    the UI. IsolateNameServer does not cross process boundaries, so we cannot
  //    share a DriftIsolate server with the UI. Each process opens the file
  //    independently.
  //
  // 2. NativeDatabase avoids spawning an extra Drift Worker isolate on top of
  //    the background service's own isolate, keeping the process lightweight.
  //
  // SQLite WAL mode (enabled explicitly below) is designed for this pattern:
  // multiple concurrent readers + one writer. The background service is the
  // sole writer; the UI isolate only reads (during session restore). This is
  // safe without additional locking.
  final dbDir = await getApplicationDocumentsDirectory();
  final dbFile = File(p.join(dbDir.path, 'workout_db.sqlite'));

  final db = WorkoutDatabase(
    NativeDatabase(
      dbFile,
      setup: (rawDb) {
        // Enable WAL mode so the UI can read concurrently while we write.
        rawDb.execute('PRAGMA journal_mode=WAL;');
        rawDb.execute('PRAGMA synchronous=NORMAL;');
      },
    ),
  );

  backgroundGetIt
    ..registerSingleton<WorkoutDatabase>(db)
    ..registerSingleton<LocalWorkoutSessionRepository>(
      LocalWorkoutSessionRepositoryImpl(db),
    );

  // ── Tracking engines ───────────────────────────────────────────────────────
  // Both engines self-contain their own state (KalmanFilter, step counters).
  // They are registered as singletons so [RunningSessionManager] can hold
  // stable references across pause/resume cycles.
  final gpsEngine = GpsTrackingEngine();
  final pedometerEngine = PedometerTrackingEngine();

  backgroundGetIt
    ..registerSingleton<TrackingEngine>(gpsEngine, instanceName: 'gps')
    ..registerSingleton<TrackingEngine>(pedometerEngine, instanceName: 'pedometer');

  // ── Audio Feedback ─────────────────────────────────────────────────────────
  final audioService = AudioFeedbackService();
  await audioService.init();
  backgroundGetIt.registerSingleton<AudioFeedbackService>(audioService);

  // ── Session manager ────────────────────────────────────────────────────────
  // ignore: cascade_invocations
  backgroundGetIt.registerSingleton<RunningSessionManager>(
    RunningSessionManager(
      pedometerEngine,
      gpsEngine,
      backgroundGetIt<LocalWorkoutSessionRepository>(),
      audioService,
    ),
  );
}
