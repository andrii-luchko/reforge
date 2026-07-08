import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/constants/measure_system.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/date_of_birth.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/analytics/domain/analytics_user_properties.dart';
import 'package:reforge/core/analytics/domain/helpers/anonymization_helpers.dart';
import 'package:reforge/features/quiz/data/models/quiz_answers.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/quiz/domain/enums/quiz_steps.dart';
import 'package:reforge/features/quiz/domain/enums/training_level.dart';
import 'package:reforge/features/quiz/domain/repositories/quiz_repository.dart';

part 'quiz_cubit.freezed.dart';
part 'quiz_state.dart';

@injectable
class QuizCubit extends Cubit<QuizState> {
  QuizCubit(this._quizRepository, this._analytics) : super(const QuizState()) {
    unawaited(_analytics.logEvent(AnalyticsEvents.quizStart));
  }

  final QuizRepository _quizRepository;
  final AnalyticsService _analytics;

  bool get isStepValid {
    final currentStep = QuizSteps.values[state.currentStep];

    return switch (currentStep) {
      QuizSteps.dateBirthStep => state.dateOfBirth != null && state.dateOfBirthError == null,
      QuizSteps.measurementSystemStep => true,
      QuizSteps.bodyWeightStep => state.bodyWeight != null,
      QuizSteps.mainGoalStep => state.mainGoal != null,
      QuizSteps.trainingLevelStep => state.trainingLevel != null,
      QuizSteps.workoutFrequencyStep =>
        (state.workoutDaysPerWeek != null &&
            state.workoutDaysPerWeek! > 0 &&
            state.specificWorkoutDays.isNotEmpty &&
            state.workoutDaysPerWeek == state.specificWorkoutDays.length),
      //QuizSteps.selectMainFactionStep => state.mainFaction != null,
      QuizSteps.selectSecondFactionStep => true,
    };
  }

  void onStepChanged(int index) {
    emit(state.copyWith(currentStep: index));
  }

  void setDateOfBirth(DateTime? date) {
    final error = validateDateOfBirth(date);
    emit(state.copyWith(dateOfBirth: date, dateOfBirthError: error));
  }

  void setMeasurementSystem(MeasurementSystem system) {
    emit(state.copyWith(measurementSystem: system));
  }

  void setBodyWeight(int bodyWeight) {
    emit(state.copyWith(bodyWeight: bodyWeight));
  }

  void setMainGoal(MainGoal goal) {
    emit(
      state.copyWith(
        mainGoal: goal,
        mainFaction: goal.faction,
      ),
    );
  }

  void setTrainingLevel(TrainingLevel level) {
    emit(state.copyWith(trainingLevel: level));
  }

  void setWorkoutDays(int daysCount) {
    emit(state.copyWith(workoutDaysPerWeek: daysCount));
  }

  void setSpecificDays(List<WeekDay> specificDays) {
    emit(state.copyWith(specificWorkoutDays: specificDays));
  }

  void setMainFaction(Faction faction) {
    emit(state.copyWith(mainFaction: faction));
  }

  // void setSecondFaction(Faction faction) {
  //   emit(state.copyWith(secondFaction: faction));
  // }

  void toggleSecondFaction(Faction faction) {
    final currentList = List<Faction>.from(state.secondFactions);

    if (currentList.contains(faction)) {
      currentList.remove(faction);
    } else {
      currentList.add(faction);
    }

    emit(state.copyWith(secondFactions: currentList));
  }

  bool get isFormComplete {
    return
    // 1. dateBirthStep
    state.dateOfBirth != null &&
        // 2. measurementSystemStep
        state.bodyWeight != null &&
        // 3. mainGoalStep
        state.mainGoal != null &&
        // 4. trainingLevelStep
        state.trainingLevel != null &&
        // 5. workoutFrequencyStep
        (state.workoutDaysPerWeek != null && state.workoutDaysPerWeek! > 0 && state.specificWorkoutDays.isNotEmpty) &&
        // 6. selectMainFactionStep
        state.mainFaction != null;

    // 7. selectSecondFactionStep
  }

  Future<void> onSubmit() async {
    if (!isFormComplete) {
      return;
    }
    emit(state.copyWith(isLoading: true));

    final answers = QuizAnswers(
      dateOfBirth: state.dateOfBirth!,
      measurementSystem: state.measurementSystem,
      bodyWeight: state.bodyWeight!,
      mainGoal: state.mainGoal!,
      trainingLevel: state.trainingLevel!,
      workoutDaysPerWeek: state.workoutDaysPerWeek!,
      specificWorkoutDays: state.specificWorkoutDays.map((e) => e.value).toList(),
      mainFaction: state.mainFaction!,
      secondFaction: state.secondFactions.firstOrNull,
    );

    final result = await _quizRepository.submitQuiz(answers);

    switch (result) {
      case Success(value: _):
        final weightInKg = answers.measurementSystem == MeasurementSystem.metric
            ? answers.bodyWeight.toDouble()
            : MeasureSystemValues.toKg(answers.bodyWeight.toDouble());
        final ageGroupVal = AnonymizationHelpers.ageGroup(answers.dateOfBirth);
        final weightRangeVal = AnonymizationHelpers.weightBucket(weightInKg);

        unawaited(
          _analytics.logEvent(
            AnalyticsEvents.quizComplete,
            {
              'main_goal': answers.mainGoal.name,
              'training_level': answers.trainingLevel.name,
              'workouts_per_week': answers.workoutDaysPerWeek,
              'main_faction_id': answers.mainFaction.id,
              'has_second_faction': answers.secondFaction != null,
              'weight_range': weightRangeVal,
              'age_group': ageGroupVal,
            },
          ),
        );

        unawaited(
          _analytics.setUserProperty(
            AnalyticsUserProperties.measurementSystem,
            answers.measurementSystem.name,
          ),
        );
        unawaited(
          _analytics.setUserProperty(
            AnalyticsUserProperties.factionId,
            '${answers.mainFaction.id}',
          ),
        );
        unawaited(
          _analytics.setUserProperty(
            AnalyticsUserProperties.workoutsPerWeek,
            '${answers.workoutDaysPerWeek}',
          ),
        );
        unawaited(
          _analytics.setUserProperty(
            AnalyticsUserProperties.ageGroup,
            ageGroupVal,
          ),
        );
        unawaited(
          _analytics.setUserProperty(
            AnalyticsUserProperties.weightRange,
            weightRangeVal,
          ),
        );

        emit(state.copyWith(isSubmitted: true, isLoading: false));

      case Failure(error: _):
        emit(
          state.copyWith(
            isSubmitted: false,
            isLoading: false,
            apiError: result.error.toString(),
          ),
        );
    }
  }
}
