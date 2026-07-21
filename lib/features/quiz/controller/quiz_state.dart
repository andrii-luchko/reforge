part of 'quiz_cubit.dart';

@freezed
sealed class QuizState with _$QuizState {
  const factory QuizState({
    @Default(0) int currentStep,
    DateTime? dateOfBirth,
    String? dateOfBirthError,

    @Default(MeasurementSystem.metric) MeasurementSystem measurementSystem,

    double? bodyWeight,

    MainGoal? mainGoal,

    TrainingLevel? trainingLevel,

    int? workoutDaysPerWeek,
    String? workoutDaysError,

    @Default([]) List<WeekDay> specificWorkoutDays,
    String? specificWorkoutDaysError,

    Faction? mainFaction,

    @Default([]) List<Faction> secondFactions,
    String? secondFactionError,

    @Default(false) bool isLoading,
    @Default(false) bool isSubmitted,

    String? apiError,
  }) = _QuizState;
}
