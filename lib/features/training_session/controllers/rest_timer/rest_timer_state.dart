part of 'rest_timer_cubit.dart';

@freezed
sealed class RestTimerState with _$RestTimerState {
  const factory RestTimerState({
    @Default(0) int remainingSeconds,
    @Default(0) int elapsedSeconds,
    @Default(0) int targetSeconds,
    @Default(false) bool isRunning,
  }) = _RestTimerState;
}
