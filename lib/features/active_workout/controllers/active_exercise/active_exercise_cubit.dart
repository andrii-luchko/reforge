import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/workout_common/domain/entities/previous_exercise_result.dart';
import 'package:reforge/features/workout_common/models/tier.dart';
import 'package:reforge/features/workout_common/models/workout_set.dart';

import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_flow/domain/repositories/training_session_repository.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'active_exercise_cubit.freezed.dart';
part 'active_exercise_state.dart';

@injectable
class ActiveExerciseCubit extends Cubit<ActiveExerciseState> {
  ActiveExerciseCubit(
    this.repository,
    this._analytics,
    @factoryParam this.workoutSessionId,
    @factoryParam this.programExercise,
  ) : super(const ActiveExerciseState()) {
    unawaited(_init());
  }

  final TrainingSessionRepository repository;
  final AnalyticsService _analytics;
  final int workoutSessionId;
  final ProgramExerciseEntity programExercise;

  Future<void> _init() async {
    emit(state.copyWith(isLoading: true));

    final measurementSystem = repository.getUserMeasurementSystem() ?? MeasurementSystem.metric;

    final previousResult = await _getPreviousResult(measurementSystem);

    emit(
      state.copyWith(
        isLoading: false,
        previousResult: previousResult,
        sets: [WorkoutSet(id: DateTime.now().microsecondsSinceEpoch)],
        measureSystem: measurementSystem,
      ),
    );
  }

  Future<PreviousExerciseResult?> _getPreviousResult(MeasurementSystem system) async {
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
          name: programExercise.exerciseDetails.name,
          description: programExercise.exerciseDetails.description,
          metrics: programExercise.exerciseDetails.metrics,
          imageUrl: programExercise.exerciseDetails.thumbnailInstructionUrl,
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
    final newSet = WorkoutSet(id: DateTime.now().microsecondsSinceEpoch);
    emit(state.copyWith(sets: [...state.sets, newSet]));
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

    final metrics = programExercise.exerciseDetails.metrics;

    if (!currentSet.isValid(metrics)) {
      emit(state.copyWith(setValidationError: t.workout_validation.fillAllFields));
      return;
    }

    emit(state.copyWith(isSendingSet: true, setValidationError: null));

    updateSet(setId, currentSet.copyWith(isBusy: true));

    final tier = programExercise.exerciseDetails.isTiered ? state.selectedTier?.rank : null;

    final result = await repository.completeSet(
      exerciseId: programExercise.exerciseDetails.id,
      workoutProgramExerciseId: programExercise.id,
      workoutSessionId: workoutSessionId,
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
              'exercise_id': programExercise.exerciseDetails.id,
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
name: ${programExercise.exerciseDetails.name}
loading:${state.isLoading}
submitted: ${state.isSubmitted}
''');

    if (state.isLoading) return;

    if (state.isSubmitted) return;

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
        exerciseId: programExercise.exerciseDetails.id,
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
