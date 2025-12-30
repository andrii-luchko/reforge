part of 'quiz_cubit.dart';

@freezed
sealed class QuizState with _$QuizState {
  const factory QuizState({
    DateTime? dateOfBirth,
    String? dateOfBirthError,

    @Default(MeasurementSystem.metric) MeasurementSystem measurementSystem,

    MainGoal? mainGoal,

    TrainingLevel? trainingLevel,

    int? workoutDaysPerWeek,
    String? workoutDaysError,

    @Default([]) List<WeekDay> specificWorkoutDays,
    String? specificWorkoutDaysError,

    Faction? mainFaction,

    Faction? secondFaction,
    String? secondFactionError,

    @Default(false) bool isLoading,
    @Default(false) bool isSubmitted,

    String? apiError,
  }) = _QuizState;
}
