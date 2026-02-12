part of 'calendar_cubit.dart';

@freezed
sealed class CalendarState with _$CalendarState {
  const factory CalendarState({
    @Default(false) bool isLoading,
    String? error,
  }) = _CalendarState;
}
