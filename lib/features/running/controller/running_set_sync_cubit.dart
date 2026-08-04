import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/exceptions/set_idempotency_conflict_exception.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/entities/running_exercise_config.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';

@injectable
class RunningSetSyncCubit extends Cubit<RunningSetSyncState> {
  RunningSetSyncCubit(
    this._localRepository,
    this._exerciseSessionRepository,
    @factoryParam this.config,
  ) : super(const RunningSetSyncState());

  final LocalWorkoutSessionRepository _localRepository;
  final ExerciseSessionRepository _exerciseSessionRepository;
  final RunningExerciseConfig config;

  StreamSubscription<List<ActiveRunningSet>>? _databaseSubscription;
  final Map<int, Future<bool>> _syncFutures = {};
  final Set<int> _syncedRowIds = {};
  final Set<int> _failedRowIds = {};
  final Set<int> _nonRetryableRowIds = {};
  List<ActiveRunningSet> _rows = const [];
  Future<void>? _initialization;
  String? _syncError;

  Future<void> init({
    Iterable<WorkoutSet> restoredSets = const [],
    MeasurementSystem restoredSetSystem = MeasurementSystem.metric,
  }) => _initialization ??= _init(restoredSets, restoredSetSystem);

  Future<void> _init(
    Iterable<WorkoutSet> restoredSets,
    MeasurementSystem restoredSetSystem,
  ) async {
    for (final set in restoredSets) {
      final clientSetId = set.clientSetId;
      if (clientSetId == null) continue;
      final metricSet = restoredSetSystem == MeasurementSystem.imperial ? set.toMetric() : set;
      await _localRepository.reconcileSetAsSynced(
        sessionId: config.workoutSessionId,
        exerciseSessionId: config.exerciseSessionId,
        clientSetId: clientSetId,
        remoteSetId: set.id,
        durationSeconds: metricSet.time?.inSeconds ?? 0,
        distanceMeters: (metricSet.distance ?? 0) * 1000,
        speedKmH: metricSet.pace ?? 0,
        programSegmentId: metricSet.programSegmentId,
      );
    }
    await _localRepository.recoverInterruptedSetSyncs();
    if (isClosed) return;

    _databaseSubscription = _localRepository
        .watchActiveRunningSets(
          sessionId: config.workoutSessionId,
          exerciseSessionId: config.exerciseSessionId,
          workoutProgramExerciseId: config.workoutProgramExerciseId,
        )
        .listen(_onDatabaseRowsChanged);
  }

  void _onDatabaseRowsChanged(List<ActiveRunningSet> rows) {
    _rows = rows
        .where(
          (row) =>
              row.exerciseSessionId == config.exerciseSessionId ||
              (row.exerciseSessionId == null && row.programExerciseId == config.workoutProgramExerciseId),
        )
        .toList();

    for (final row in _rows) {
      if (row.isSynced) {
        _syncedRowIds.add(row.id);
        _failedRowIds.remove(row.id);
      } else if (row.hasSyncFailed) {
        _failedRowIds.add(row.id);
      }
    }
    _emitState();

    for (final row in _rows.where((row) => row.isLocallyCompleted)) {
      unawaited(_syncRunningSet(row));
    }
  }

  WorkoutSet _mapRowToSet(ActiveRunningSet row) {
    return WorkoutSet(
      id: row.id,
      clientSetId: row.clientSetId,
      distance: (row.distanceMeters ?? 0) / 1000,
      time: Duration(seconds: row.durationSeconds ?? 0),
      pace: row.avgSpeedKmH ?? 0,
      setNumber: row.setNumber,
      isLocallyCompleted: !row.isTracking,
      isDone: row.isSynced || _syncedRowIds.contains(row.id),
      isBusy: row.isTracking || row.isSyncing || _syncFutures.containsKey(row.id),
      programSegmentId: row.programSegmentId,
    );
  }

  /// Retries every completed unsynced row once and waits for those requests.
  /// Returns true only when every local row has been synced.
  Future<bool> flush() async {
    await init();
    if (_rows.isEmpty || _rows.any((row) => row.isTracking)) return false;

    final pending = _rows.where(
      (row) => !row.isSynced && !_syncedRowIds.contains(row.id) && !_nonRetryableRowIds.contains(row.id),
    );
    final results = await Future.wait(pending.map(_syncRunningSet));
    _emitState();
    return _nonRetryableRowIds.isEmpty && results.every((success) => success) && state.canFinish;
  }

  Future<bool> _syncRunningSet(ActiveRunningSet row) {
    final inFlight = _syncFutures[row.id];
    if (inFlight != null) return inFlight;
    if (row.isSynced || _syncedRowIds.contains(row.id)) return Future.value(true);

    final future = _syncRunningSetOnce(row);
    _syncFutures[row.id] = future;
    _failedRowIds.remove(row.id);
    _syncError = null;
    _emitState();
    return future.whenComplete(() {
      final _ = _syncFutures.remove(row.id);
      _emitState();
    });
  }

  Future<bool> _syncRunningSetOnce(ActiveRunningSet row) async {
    await _localRepository.markSetAsSyncing(row.id);

    final result = await _exerciseSessionRepository.completeSet(
      exerciseId: config.exercise.id,
      workoutSessionId: config.workoutSessionId,
      exerciseSessionId: config.exerciseSessionId,
      workoutProgramExerciseId: config.workoutProgramExerciseId,
      system: MeasurementSystem.metric,
      set: _mapRowToSet(row),
    );

    return result.fold(
      onSuccess: (identity) async {
        final echoedClientSetId = identity.clientSetId;
        if (echoedClientSetId != null && echoedClientSetId != row.clientSetId) {
          const message = 'Backend returned a different clientSetId for a running set.';
          await _localRepository.markSetSyncFailed(row.id);
          _failedRowIds.add(row.id);
          _syncError = message;
          logger.e(message);
          return false;
        }

        await _localRepository.markSetAsSynced(
          row.id,
          remoteSetId: identity.remoteSetId,
        );
        _syncedRowIds.add(row.id);
        _failedRowIds.remove(row.id);
        _nonRetryableRowIds.remove(row.id);
        return true;
      },
      onError: (error, stackTrace) async {
        await _localRepository.markSetSyncFailed(row.id);
        _failedRowIds.add(row.id);
        if (error is SetIdempotencyConflictException) {
          _nonRetryableRowIds.add(row.id);
        }
        _syncError = error.toString();
        logger.e('Failed to sync running set ${row.id}', error, stackTrace);
        return false;
      },
    );
  }

  void _emitState() {
    if (isClosed) return;
    final sets = _rows.map(_mapRowToSet).toList();
    final isSending = _syncFutures.isNotEmpty || _rows.any((row) => row.isTracking || row.isSyncing);
    final hasSyncFailures = _failedRowIds.isNotEmpty || _rows.any((row) => row.hasSyncFailed);
    final canFinish = sets.isNotEmpty && sets.every((set) => set.isDone);

    emit(
      RunningSetSyncState(
        sets: sets,
        isSending: isSending,
        hasPendingSync: sets.any((set) => !set.isDone && !set.isBusy),
        hasSyncFailures: hasSyncFailures,
        canFinish: canFinish,
        error: _syncError,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _databaseSubscription?.cancel();
    return super.close();
  }
}

class RunningSetSyncState {
  const RunningSetSyncState({
    this.sets = const [],
    this.isSending = false,
    this.hasPendingSync = false,
    this.hasSyncFailures = false,
    this.canFinish = false,
    this.error,
  });

  final List<WorkoutSet> sets;
  final bool isSending;
  final bool hasPendingSync;
  final bool hasSyncFailures;
  final bool canFinish;
  final String? error;
}
