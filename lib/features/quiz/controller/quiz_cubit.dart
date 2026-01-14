import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/constants/week_day.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/validators/date_of_birth.dart';
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
  QuizCubit(this._quizRepository) : super(const QuizState());

  final QuizRepository _quizRepository;

  bool canProceedToNextStep(int stepIndex) {
    final currentStep = QuizSteps.values[stepIndex];

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
      QuizSteps.selectMainFactionStep => state.mainFaction != null,
      QuizSteps.selectSecondFactionStep => state.secondFaction != state.mainFaction,
    };
  }

  void setDateOfBirth(DateTime date) {
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
    emit(state.copyWith(mainGoal: goal));
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

  void setSecondFaction(Faction faction) {
    emit(state.copyWith(secondFaction: faction));
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
      secondFaction: state.secondFaction!,
    );

    final result = await _quizRepository.submitQuiz(answers);

    switch (result) {
      case Success(value: _):
        emit(state.copyWith(isSubmitted: true, isLoading: false));

      case Error(error: _):
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
