import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';
import 'package:reforge/features/workout_flow/data/enums/workout_session_status.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_day_entity.dart';
import 'package:reforge/features/workout_flow/domain/entities/program_exercise_entity.dart';
import 'package:reforge/features/workout_flow/domain/repositories/training_session_repository.dart';

part 'workout_flow_state.dart';
part 'workout_flow_cubit.freezed.dart';

@lazySingleton
class WorkoutFlowCubit extends Cubit<WorkoutFlowState> {
  WorkoutFlowCubit(this._repository, this._analytics) : super(const WorkoutFlowState()) {
    unawaited(init());
  }

  final TrainingSessionRepository _repository;
  final AnalyticsService _analytics;

  Future<void> _loadProgramDay(int programDayId) async {
    emit(state.copyWith(isLoading: true));
    final result = await _repository.getWorkoutByDay(programDayId);
    switch (result) {
      case Success(value: final programDay):
        emit(state.copyWith(isLoading: false, programDay: programDay, currentExerciseIndex: 0));
      case ErrorR(error: final error):
        emit(state.copyWith(isLoading: false, programDay: null, error: error.toString()));
    }
  }

  Future<void> init() async {
    final currentDay = _repository.getUserCurrentProgramDayId() ?? DateTime.now().weekday;
    await _loadProgramDay(currentDay);
  }

  Future<void> initScheduled(int programDayId) async {
    await _loadProgramDay(programDayId);
  }

  Future<void> startWorkout() async {
    final workoutProgramDayId = state.programDay?.id;
    if (workoutProgramDayId == null) return;

    emit(state.copyWith(isStartingWorkout: true, error: null));

    final result = await _repository.startWorkoutSession(workoutProgramDayId);

    switch (result) {
      case Success(value: final sessionData):
        unawaited(_analytics.logEvent(AnalyticsEvents.workoutStart));
        emit(
          state.copyWith(
            isStartingWorkout: false,
            workoutSessionId: sessionData.id,
            sessionStatus: WorkoutSessionStatus.active,
          ),
        );
      case ErrorR(error: final error):
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
      await _finishWorkout(WorkoutSessionStatus.completed, workoutSessionDuration);
    }
  }

  Future<void> cancelWorkout(int workoutSessionDuration) async {
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
        if (status == WorkoutSessionStatus.completed) {
          unawaited(_analytics.logEvent(AnalyticsEvents.workoutComplete));
          if (summary.isLevelUp && summary.currentLevel != null) {
            unawaited(_analytics.logEvent(AnalyticsEvents.workoutLevelUp, {'level': summary.currentLevel}));
          }
        } else if (status == WorkoutSessionStatus.canceled) {
          unawaited(_analytics.logEvent(AnalyticsEvents.workoutCancel));
        }
        emit(
          state.copyWith(sessionStatus: status, summary: summary, isLoading: false),
        );
      case ErrorR(error: final error):
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
