part of 'timer_cubit.dart';

@freezed
sealed class TimerState with _$TimerState {
  const factory TimerState({
    @Default(0) int duration,
    @Default(false) bool isRunning,
  }) = _TimerState;
}
