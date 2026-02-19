import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/workout_quiz/data/models/workout_quiz_answers.dart';
import 'package:reforge/features/workout_quiz/domain/enums/body_feel.dart';
import 'package:reforge/features/workout_quiz/domain/enums/energized_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/hydrated_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/sleep_quality.dart';
import 'package:reforge/features/workout_quiz/domain/enums/stress_level.dart';
import 'package:reforge/features/workout_quiz/domain/enums/work_out_quiz_steps.dart';
import 'package:reforge/features/workout_quiz/domain/repositories/workout_quiz_repository.dart';

part 'workout_quiz_cubit.freezed.dart';
part 'workout_quiz_state.dart';

@injectable
class WorkoutQuizCubit extends Cubit<WorkoutQuizState> {
  WorkoutQuizCubit(this._workoutQuizRepository, this._analytics) : super(const WorkoutQuizState());

  final WorkoutQuizRepository _workoutQuizRepository;
  final AnalyticsService _analytics;

  bool get isStepValid {
    final currentStep = WorkOutQuizSteps.values[state.currentStep];

    return switch (currentStep) {
      WorkOutQuizSteps.sleepQualityStep => state.sleepQuality != null,
      WorkOutQuizSteps.energizedLevelStep => state.energizedLevel != null,
      WorkOutQuizSteps.stressLevelStep => state.stressLevel != null,
      WorkOutQuizSteps.bodyFellStep => state.bodyFeel != null,
      WorkOutQuizSteps.hydratedLevelStep => state.hydratedLevel != null,
      WorkOutQuizSteps.hasEatenRecentlyStep => true,
      WorkOutQuizSteps.isMorningSessionStep => true,
    };
  }

  Future<bool> isTodaySubmitted() async {
    //if we already submitted return true
    if (isFormComplete && state.isSubmitted) return true;

    emit(state.copyWith(isLoading: true, apiError: null));

    final result = await _workoutQuizRepository.isQuizTodaySubmitted();
    logger.d(result);

    switch (result) {
      case Success(value: _):
        emit(state.copyWith(isSubmitted: result.value, isLoading: false));
        return result.value;

      case ErrorR(error: final error):
        emit(state.copyWith(isSubmitted: false, isLoading: false, apiError: error.toString()));
        return false;
    }
  }

  void onStepChanged(int index) {
    emit(state.copyWith(currentStep: index));
  }

  void setSleepQuality(SleepQuality value) {
    emit(state.copyWith(sleepQuality: value));
  }

  void setEnergizedLevel(EnergizedLevel value) {
    emit(state.copyWith(energizedLevel: value));
  }

  void setStressLevel(StressLevel value) {
    emit(state.copyWith(stressLevel: value));
  }

  void setBodyFeel(BodyFeel value) {
    emit(state.copyWith(bodyFeel: value));
  }

  void setHydratedLevel(HydratedLevel value) {
    emit(state.copyWith(hydratedLevel: value));
  }

  // ignore: avoid_positional_boolean_parameters
  void setHasEatenRecently(bool value) {
    emit(state.copyWith(hasEatenRecently: value));
  }

  // ignore: avoid_positional_boolean_parameters
  void setIsMorningSession(bool value) {
    emit(state.copyWith(isMorningSession: value));
  }

  bool get isFormComplete {
    return state.sleepQuality != null &&
        state.energizedLevel != null &&
        state.stressLevel != null &&
        state.bodyFeel != null &&
        state.hydratedLevel != null;
  }

  Future<void> onSubmit() async {
    if (!isFormComplete) {
      return;
    }

    emit(state.copyWith(isLoading: true, apiError: null));

    final answers = WorkoutQuizAnswers(
      sleepQuality: state.sleepQuality!,
      energizedLevel: state.energizedLevel!,
      stressLevel: state.stressLevel!,
      bodyFeel: state.bodyFeel!,
      hydratedLevel: state.hydratedLevel!,
      hasEatenRecently: state.hasEatenRecently,
      isMorningSession: state.isMorningSession,
    );

    final result = await _workoutQuizRepository.submitQuiz(answers);

    switch (result) {
      case Success(value: _):
        unawaited(_analytics.logEvent(AnalyticsEvents.workoutQuizComplete));
        emit(
          state.copyWith(
            isLoading: false,
            isSubmitted: true,
          ),
        );
      case ErrorR(error: final error):
        emit(
          state.copyWith(
            isLoading: false,
            isSubmitted: false,
            apiError: error.toString(),
          ),
        );
    }
  }
}
