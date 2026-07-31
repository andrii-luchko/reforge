import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/database/database.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/repositories/local_workout_session_repository.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';

@injectable
class RunningSetSyncCubit extends Cubit<RunningSetSyncState> {
  RunningSetSyncCubit(
    this._localRepository,
    this._exerciseSessionRepository,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const RunningSetSyncState());

  final LocalWorkoutSessionRepository _localRepository;
  final ExerciseSessionRepository _exerciseSessionRepository;
  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  StreamSubscription<List<ActiveRunningSet>>? _databaseSubscription;
  final Set<int> _syncingRowIds = {};
  bool _isInitialized = false;

  void init() {
    if (_isInitialized) return;
    _isInitialized = true;

    _databaseSubscription = _localRepository
        .watchActiveRunningSets(
          sessionId: workoutSessionId,
          programExerciseId: programExercise.id,
        )
        .listen(_onDatabaseRowsChanged);
  }

  void _onDatabaseRowsChanged(List<ActiveRunningSet> rows) {
    final exerciseRows = rows.where((row) => row.programExerciseId == programExercise.id).toList();
    final mappedSets = exerciseRows.map(_mapRowToSet).toList();

    emit(
      RunningSetSyncState(
        sets: mappedSets,
        isSending: _syncingRowIds.isNotEmpty,
      ),
    );

    for (final row in exerciseRows.where((row) => row.readyToSync)) {
      unawaited(_syncRunningSet(row));
    }
  }

  WorkoutSet _mapRowToSet(ActiveRunningSet row) {
    return WorkoutSet(
      id: row.id,
      distance: (row.distanceMeters ?? 0) / 1000,
      time: Duration(seconds: row.durationSeconds ?? 0),
      pace: row.avgSpeedKmH ?? 0,
      setNumber: row.setNumber,
      isDone: row.isDone || row.readyToSync,
      isBusy: row.isBusy,
      programSegmentId: row.programSegmentId,
    );
  }

  Future<void> _syncRunningSet(ActiveRunningSet row) async {
    if (_syncingRowIds.contains(row.id)) return;
    _syncingRowIds.add(row.id);
    _emitSendingState();

    try {
      final set = state.sets.firstWhereOrNull((item) => item.id == row.id) ?? _mapRowToSet(row);
      final result = await _exerciseSessionRepository.completeSet(
        exerciseId: programExercise.exerciseDetails.id,
        workoutProgramExerciseId: programExercise.id,
        workoutSessionId: workoutSessionId,
        system: MeasurementSystem.metric,
        set: set,
      );

      await result.fold(
        onSuccess: (_) => _localRepository.markSetAsDone(row.id),
        onError: (error, stackTrace) async {
          logger.e(
            'Failed to sync running set ${row.id}, retrying in 3s...',
            error,
            stackTrace,
          );
          _syncingRowIds.remove(row.id);
          _emitSendingState();

          await Future<void>.delayed(const Duration(seconds: 3));
          if (!isClosed) unawaited(_syncRunningSet(row));
        },
      );
    } finally {
      _syncingRowIds.remove(row.id);
      _emitSendingState();
    }
  }

  void _emitSendingState() {
    if (isClosed) return;
    emit(
      RunningSetSyncState(
        sets: state.sets,
        isSending: _syncingRowIds.isNotEmpty,
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
  });

  final List<WorkoutSet> sets;
  final bool isSending;
}
