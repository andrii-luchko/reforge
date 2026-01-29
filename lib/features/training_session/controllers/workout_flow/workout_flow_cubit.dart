import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/training_session/data/enums/workout_session_status.dart';
import 'package:reforge/features/training_session/data/mock/mocked_day.dart';
import 'package:reforge/features/training_session/data/models/program_day.dart';
import 'package:reforge/features/training_session/data/models/program_exercise.dart';
import 'package:reforge/features/training_session/data/models/workout_summary.dart';
import 'package:reforge/features/training_session/domain/repositories/training_session_repository.dart';

part 'workout_flow_state.dart';
part 'workout_flow_cubit.freezed.dart';

@lazySingleton
class WorkoutFlowCubit extends Cubit<WorkoutFlowState> {
  WorkoutFlowCubit(this._repository) : super(const WorkoutFlowState()) {
    unawaited(init());
  }

  final TrainingSessionRepository _repository;

  Future<void> init() async {
    //  if (state.programDay != null) return;

    emit(state.copyWith(isLoading: true, programDay: mockProgramDay));

    final currentDay = _repository.getUserCurrentProgramDayId() ?? DateTime.now().weekday;

    final result = await _repository.getWorkoutByDay(currentDay);

    switch (result) {
      case Success(value: final programDay):
        emit(
          state.copyWith(
            isLoading: false,
            programDay: programDay,
            currentExerciseIndex: 0,
          ),
        );
      case Error(error: final error):
        emit(
          state.copyWith(
            isLoading: false,
            programDay: null,
            error: error.toString(),
          ),
        );
    }
  }

  Future<void> startWorkout() async {
    final workoutProgramDayId = state.programDay?.id;
    if (workoutProgramDayId == null) return;

    emit(state.copyWith(isStartingWorkout: true, error: null));

    final result = await _repository.startWorkoutSession(workoutProgramDayId);

    switch (result) {
      case Success(value: final sessionData):
        emit(
          state.copyWith(
            isStartingWorkout: false,
            workoutSessionId: sessionData.id,
            sessionStatus: WorkoutSessionStatus.active,
          ),
        );
      case Error(error: final error):
        emit(
          state.copyWith(
            isStartingWorkout: false,
            error: 'Failed to start workout: $error',
          ),
        );
    }
  }

  Future<void> nextExercise(int workoutSessionDuration) async {
    final nextIndex = state.currentExerciseIndex + 1;
    final total = state.totalExercises;

    if (nextIndex < total) {
      emit(state.copyWith(currentExerciseIndex: nextIndex));
    } else {
      await _finishWorkout(.completed, workoutSessionDuration);
    }
  }

  Future<void> cancelWorkout(int workoutSessionDuration) async {
    // Если уже отменено или закончено - ничего не делаем, чтобы не спамить в UI
    if (state.isFinished) return;

    await _finishWorkout(WorkoutSessionStatus.canceled, workoutSessionDuration);
  }

  Future<void> _finishWorkout(WorkoutSessionStatus status, int workoutSessionDuration) async {
    final currentState = state;
    final workoutSessionId = currentState.workoutSessionId;

    if (workoutSessionId == null) {
      emit(state.copyWith(sessionStatus: status, isLoading: false));
      return;
    }

    emit(state.copyWith(isLoading: true));

    final result = await _repository.endWorkoutSession(
      status: status,
      workoutSessionId: workoutSessionId,
      workoutSessionDuration: workoutSessionDuration,
    );

    switch (result) {
      case Success(value: final summary):
        emit(
          state.copyWith(sessionStatus: status, summary: summary, isLoading: false),
        );
      case Error(error: final error):
        emit(
          state.copyWith(
            sessionStatus: status,
            error: 'Failed to sync cancel: $error',
            isLoading: false,
          ),
        );
    }
  }
}
