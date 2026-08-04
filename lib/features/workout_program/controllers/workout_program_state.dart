part of 'workout_program_cubit.dart';

@freezed
sealed class WorkoutProgramState with _$WorkoutProgramState {
  const factory WorkoutProgramState({
    ProgramDayEntity? programDay,
    @Default(true) bool isLoading,
    String? error,
  }) = _WorkoutProgramState;
}
