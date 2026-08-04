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
import 'package:reforge/core/user/domain/services/user_session_service.dart';
import 'package:reforge/features/exercise_session/data/models/workout_set.dart';
import 'package:reforge/features/exercise_session/domain/entities/exercise_swap_context.dart';
import 'package:reforge/features/exercise_session/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/exercise_session/domain/entities/workout_exercise_session_entity.dart';
import 'package:reforge/features/exercise_session/domain/repositories/exercise_session_repository.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_program/data/models/tier.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_session/domain/entities/active_workout_exercise_context.dart';
import 'package:reforge/generated/i18n/translations.g.dart';
import 'package:uuid/uuid.dart';

part 'active_exercise_cubit.freezed.dart';
part 'active_exercise_state.dart';

@injectable
class ActiveExerciseCubit extends Cubit<ActiveExerciseState> {
  ActiveExerciseCubit(
    this.repository,
    this._analytics,
    this._userSessionService,
    @factoryParam this.exerciseContext,
  ) : super(
        ActiveExerciseState(
          session: exerciseContext.session,
          effectiveExercise: exerciseContext.effectiveExercise,
          notes: exerciseContext.session.notes ?? '',
        ),
      );

  final ActiveWorkoutExerciseContext exerciseContext;

  //dependencies
  final ExerciseSessionRepository repository;
  final AnalyticsService _analytics;
  final UserSessionService _userSessionService;

  static const _uuid = Uuid();

  Future<void>? _initialization;

  int get workoutSessionId => state.session.workoutSessionId;

  ProgramExerciseEntity get programExercise => exerciseContext.programExercise;

  WorkoutExerciseSessionEntity get workoutExerciseSession => state.session;

  ExerciseDetailsEntity get effectiveExercise => state.effectiveExercise;

  bool get isRunningExercise =>
      state.session.isSwapped ? state.effectiveExercise.isRunningSwapCandidate : programExercise.isRunningExercise;

  bool get canSwap =>
      !state.isLoading && !state.isSendingSet && !state.isSubmitted && !state.sets.any((set) => set.isDone);

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
    final initialSets = (restored != null && restored.isNotEmpty)
        ? [
            ...restored.map((s) => s.copyWith(isDone: true)),
            _newSet(setNumber: restored.length + 1),
          ]
        : [
            _newSet(setNumber: 1),
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

  ActiveWorkoutExerciseContext? applySwap(AppliedExerciseSwap swap) {
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
      exercise: state.session.exercise ?? programExercise.exerciseDetails,
      swappedExercise: swap.exercise,
    );
    final nextContext = ActiveWorkoutExerciseContext(
      programExercise: programExercise,
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
    return nextContext;
  }

  Future<PreviousExerciseResult?> _getPreviousResult(MeasurementSystem system) async {
    if (state.session.isSwapped) return null;

    final result = await repository.getPreviousResults(
      programExerciseId: programExercise.id,
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
    logger.d(newNote);
    emit(state.copyWith(notes: newNote));
  }

  void addSet() {
    final newSet = _newSet(setNumber: state.sets.length + 1);
    emit(state.copyWith(sets: [...state.sets, newSet]));
  }

  WorkoutSet _newSet({required int setNumber}) {
    return WorkoutSet(
      id: DateTime.now().microsecondsSinceEpoch,
      clientSetId: _uuid.v7(),
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

    emit(state.copyWith(isSendingSet: true, setValidationError: null));

    updateSet(setId, currentSet.copyWith(isBusy: true));

    final tier = effectiveExercise.isTiered ? state.selectedTier?.rank : null;

    final result = await repository.completeSet(
      exerciseId: effectiveExercise.id,
      workoutSessionId: workoutSessionId,
      exerciseSessionId: state.session.id,
      workoutProgramExerciseId: programExercise.id,
      system: state.measureSystem,
      set: currentSet.copyWith(selectedTier: tier),
    );

    switch (result) {
      case Success():
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
        updateSet(setId, currentSet.copyWith(isBusy: false, isDone: true));
        emit(state.copyWith(isSendingSet: false));

      case Failure(:final error):
        updateSet(setId, currentSet.copyWith(isBusy: false, isDone: false));
        emit(state.copyWith(isSendingSet: false, error: error.toString()));
    }
  }

  Future<void> finishExercise() async {
    logger.d('''
name: ${effectiveExercise.name}
loading:${state.isLoading}
submitted: ${state.isSubmitted}
''');

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

    emit(state.copyWith(isLoading: true));

    final note = state.notes;

    if (note.isEmpty) {
      emit(state.copyWith(isLoading: false, isSubmitted: true));
    } else {
      final result = await repository.saveWorkoutNote(
        exerciseId: effectiveExercise.id,
        workoutProgramExerciseId: programExercise.id,
        workoutSessionId: workoutSessionId,

        note: note,
      );

      switch (result) {
        case Success():
          emit(state.copyWith(isLoading: false, isSubmitted: true));

        case Failure(:final error):
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
}
