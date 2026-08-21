import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/database/workout_session_cache_repository.dart';
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/running/domain/services/client_id_generator.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_session/domain/entities/active_exercise_execution.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'active_exercise_cubit.freezed.dart';
part 'active_exercise_state.dart';

@injectable
class ActiveExerciseCubit extends Cubit<ActiveExerciseState> {
  ActiveExerciseCubit(
    this.repository,
    this._analytics,
    this._userSessionService,
    this._clientIdGenerator,
    this._sessionCache,
    @factoryParam this.execution,
  ) : super(
        ActiveExerciseState(
          session: execution.session,
          effectiveExercise: execution.effectiveExercise,
          notes: execution.session.notes ?? '',
        ),
      );

  final ActiveExerciseExecution execution;

  //dependencies
  final ExerciseSessionRepository repository;
  final AnalyticsService _analytics;
  final UserSessionService _userSessionService;
  final ClientIdGenerator _clientIdGenerator;
  final WorkoutSessionCacheRepository _sessionCache;

  Future<void>? _initialization;
  Future<void> _notePersistence = Future.value();
  var _notesChanged = false;

  int get workoutSessionId => state.session.workoutSessionId;

  WorkoutExerciseSessionEntity get workoutExerciseSession => state.session;

  ExerciseDetailsEntity get effectiveExercise => state.effectiveExercise;

  int? get workoutProgramExerciseId => execution.spec.workoutProgramExerciseId;

  bool get isRunningExercise =>
      state.session.isSwapped ? state.effectiveExercise.isRunningSwapCandidate : execution.spec.isRunningExercise;

  bool get canSwap =>
      execution.spec.programBinding != null &&
      !state.isLoading &&
      !state.isSendingSet &&
      !state.isSubmitted &&
      !state.sets.any((set) => set.isDone);

  Future<void> initialize({List<WorkoutSet>? restoredSets}) {
    return _initialization ??= _initialize(restoredSets);
  }

  Future<void> _initialize(List<WorkoutSet>? restoredSets) async {
    emit(state.copyWith(isLoading: true));

    final measurementSystem =
        _userSessionService.currentUser?.map(
          newUser: (_) => null,
          onboarded: (user) => user.measurementSystem,
        ) ??
        MeasurementSystem.metric;

    final previousResult = await _getPreviousResult(measurementSystem);

    // If we have restored sets from an interrupted session, show them as completed.
    // A fresh empty set is appended so the user can continue recording.
    final restored = restoredSets;
    final targetSetCount = execution.spec.targetSetCount ?? 1;
    final initialSets = (restored != null && restored.isNotEmpty)
        ? [
            ...restored.map((s) => s.copyWith(isDone: true)),
            _newSet(setNumber: restored.length + 1),
          ]
        : [
            for (var setNumber = 1; setNumber <= targetSetCount; setNumber++) _newSet(setNumber: setNumber),
          ];

    emit(
      state.copyWith(
        isLoading: false,
        previousResult: previousResult,
        sets: initialSets,
        measureSystem: measurementSystem,
      ),
    );
  }

  void replaceSetsFromExternalSource({
    required List<WorkoutSet> sets,
    required bool isSending,
  }) {
    emit(state.copyWith(sets: sets, isSendingSet: isSending));
  }

  ActiveExerciseExecution? applySwap(AppliedExerciseSwap swap) {
    if (execution.spec.programBinding == null) return null;
    if (!swap.isConfirmed || swap.session.id != state.session.id) return null;

    final response = swap.session;
    final normalizedSession = WorkoutExerciseSessionEntity(
      id: response.id,
      exerciseId: response.exerciseId,
      workoutSessionId: response.workoutSessionId,
      workoutProgramExerciseId: response.workoutProgramExerciseId,
      isSwapped: true,
      swappedExerciseId: swap.exercise.id,
      isActive: response.isActive,
      notes: state.notes,
      lastCompletedSet: null,
      createdAt: response.createdAt ?? state.session.createdAt,
      updatedAt: response.updatedAt,
      sets: const [],
      exercise: state.session.exercise ?? execution.spec.details,
      swappedExercise: swap.exercise,
    );
    final nextExecution = ActiveExerciseExecution(
      spec: execution.spec,
      workoutSessionId: execution.workoutSessionId,
      session: normalizedSession,
      effectiveExercise: swap.exercise,
    );
    final replacementSets = swap.exercise.isRunningSwapCandidate ? const <WorkoutSet>[] : [_newSet(setNumber: 1)];

    emit(
      state.copyWith(
        session: normalizedSession,
        effectiveExercise: swap.exercise,
        sets: replacementSets,
        selectedTier: null,
        previousResult: null,
        error: null,
        setValidationError: null,
      ),
    );
    return nextExecution;
  }

  Future<PreviousExerciseResult?> _getPreviousResult(MeasurementSystem system) async {
    if (state.session.isSwapped) return null;
    final programExerciseId = workoutProgramExerciseId;
    if (programExerciseId == null) return null;

    final result = await repository.getPreviousResults(
      programExerciseId: programExerciseId,
      workoutSessionId: workoutSessionId,
      system: system,
    );
    switch (result) {
      case Success(:final value):
        if (value == null || value.sets == null) {
          return null;
        }
        return PreviousExerciseResult(
          name: effectiveExercise.name,
          description: effectiveExercise.description,
          metrics: effectiveExercise.metrics,
          imageUrl: effectiveExercise.thumbnailInstructionUrl,
          sets: value.sets ?? [],
          notes: value.notes,
        );

      case Failure():
        return null;
    }
  }

  void setTier(Tier newTier) {
    emit(state.copyWith(selectedTier: newTier));
  }

  void setNote(String newNote) {
    logger.d(
      'Exercise notes cached workoutSessionId=$workoutSessionId '
      'exerciseSessionId=${state.session.id} executionKey=${execution.spec.executionKey} '
      'noteLength=${newNote.length}',
    );
    emit(state.copyWith(notes: newNote));
    _notesChanged = true;
    _notePersistence = _notePersistence
        .then(
          (_) => _sessionCache.saveExerciseNotesLocally(
            workoutSessionId: workoutSessionId,
            executionKey: execution.spec.executionKey,
            notes: newNote,
          ),
        )
        .onError((error, stackTrace) {
          logger.e('ActiveExerciseCubit: failed to cache notes', error, stackTrace);
        });
    unawaited(_notePersistence);
  }

  void addSet() {
    final newSet = _newSet(setNumber: state.sets.length + 1);
    emit(state.copyWith(sets: [...state.sets, newSet]));
  }

  WorkoutSet _newSet({required int setNumber}) {
    return WorkoutSet(
      id: DateTime.now().microsecondsSinceEpoch,
      clientSetId: _clientIdGenerator.nextSetId(),
      setNumber: setNumber,
    );
  }

  void updateSet(int setId, WorkoutSet newSetData) {
    final updatedList = state.sets.map((s) {
      return s.id == setId ? newSetData : s;
    }).toList();

    emit(state.copyWith(sets: updatedList, setValidationError: null));
  }

  void removeSet(int setId) {
    final updatedList = state.sets.where((s) => s.id != setId).toList();
    emit(state.copyWith(sets: updatedList));
  }

  Future<void> markSetDone(int setId) async {
    if (state.isLoading) return;

    final currentSet = state.sets.firstWhereOrNull((s) => s.id == setId);

    if (currentSet == null || currentSet.isDone) return;

    final metrics = effectiveExercise.metrics;

    if (!currentSet.isValid(metrics)) {
      emit(state.copyWith(setValidationError: t.workout_validation.fillAllFields));
      return;
    }

    emit(
      state.copyWith(
        isSendingSet: true,
        setValidationError: null,
        error: null,
      ),
    );

    updateSet(setId, currentSet.copyWith(isBusy: true));

    logger.i(
      'Exercise set sync start workoutSessionId=$workoutSessionId '
      'exerciseSessionId=${state.session.id} clientSetId=${currentSet.clientSetId}',
    );

    final tier = effectiveExercise.isTiered ? state.selectedTier?.rank : null;

    final result = await repository.completeSet(
      exerciseId: effectiveExercise.id,
      workoutSessionId: workoutSessionId,
      exerciseSessionId: state.session.id,
      workoutProgramExerciseId: workoutProgramExerciseId,
      system: state.measureSystem,
      set: currentSet.copyWith(selectedTier: tier),
    );

    switch (result) {
      case Success():
        logger.i(
          'Exercise set sync success workoutSessionId=$workoutSessionId '
          'exerciseSessionId=${state.session.id} clientSetId=${currentSet.clientSetId}',
        );
        final setNumber = state.sets.indexWhere((s) => s.id == setId) + 1;
        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.workoutSetComplete,
            {
              'exercise_id': effectiveExercise.id,
              'set_number': setNumber,
            },
          ),
        );
        updateSet(
          setId,
          currentSet.copyWith(
            isBusy: false,
            isLocallyCompleted: true,
            isDone: true,
          ),
        );
        emit(state.copyWith(isSendingSet: false));

      case Failure(:final error):
        logger.e(
          'Exercise set sync failure workoutSessionId=$workoutSessionId '
          'exerciseSessionId=${state.session.id} clientSetId=${currentSet.clientSetId}',
          error,
        );
        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.workoutMutationFailure,
            {'boundary': 'complete_set', 'source': _sourceName},
          ),
        );
        updateSet(setId, currentSet.copyWith(isBusy: false, isDone: false));
        emit(state.copyWith(isSendingSet: false, error: error.toString()));
    }
  }

  Future<void> finishExercise() async {
    logger.d(
      'Exercise finish requested workoutSessionId=$workoutSessionId '
      'exerciseSessionId=${state.session.id} executionKey=${execution.spec.executionKey} '
      'loading=${state.isLoading} submitted=${state.isSubmitted}',
    );

    if (state.isLoading) return;

    if (state.isSubmitted) return;

    if (state.isSendingSet) return;

    if (state.sets.isEmpty) {
      emit(state.copyWith(setValidationError: t.workout_validation.completeOneSet));
      return;
    }

    if (state.sets.any((set) => !set.isDone)) {
      emit(state.copyWith(setValidationError: t.workout_validation.completeOrDeleteSets));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    await _notePersistence;
    final cachedExercise = await _sessionCache.getExerciseSession(
      workoutSessionId: workoutSessionId,
      executionKey: execution.spec.executionKey,
    );
    final shouldSyncNotes = _notesChanged || cachedExercise?.noteStatus != CachedNotesSyncStatus.synced;

    if (!shouldSyncNotes) {
      emit(state.copyWith(isLoading: false, isSubmitted: true));
    } else {
      final result = await repository.saveWorkoutNote(
        exerciseSessionId: state.session.id,
        note: state.notes,
      );

      switch (result) {
        case Success():
          logger.i(
            'Exercise notes sync success workoutSessionId=$workoutSessionId '
            'exerciseSessionId=${state.session.id} executionKey=${execution.spec.executionKey}',
          );
          await _sessionCache.markExerciseNotesSynced(
            workoutSessionId: workoutSessionId,
            executionKey: execution.spec.executionKey,
          );
          _notesChanged = false;
          emit(state.copyWith(isLoading: false, isSubmitted: true));

        case Failure(:final error):
          logger.e(
            'Exercise notes sync failure workoutSessionId=$workoutSessionId '
            'exerciseSessionId=${state.session.id} executionKey=${execution.spec.executionKey}',
            error,
          );
          unawaited(
            _analytics.logEvent(
              AnalyticsEvents.workoutMutationFailure,
              {'boundary': 'save_notes', 'source': _sourceName},
            ),
          );
          emit(
            state.copyWith(
              isLoading: false,
              isSubmitted: false,
              error: error.toString(),
            ),
          );
      }
    }
  }

  String get _sourceName => workoutProgramExerciseId == null ? 'ad_hoc' : 'program';
}
