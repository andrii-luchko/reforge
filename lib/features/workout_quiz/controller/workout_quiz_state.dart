part of 'workout_quiz_cubit.dart';

@freezed
sealed class WorkoutQuizState with _$WorkoutQuizState {
  const factory WorkoutQuizState({
    @Default(0) int currentStep,
    SleepQuality? sleepQuality,
    EnergizedLevel? energizedLevel,
    StressLevel? stressLevel,
    BodyFeel? bodyFeel,
    HydratedLevel? hydratedLevel,
    @Default(false) bool hasEatenRecently,
    @Default(false) bool isMorningSession,

    @Default(false) bool isLoading,
    @Default(false) bool isSubmitted,

    String? apiError,
  }) = _WorkoutQuizState;
}
