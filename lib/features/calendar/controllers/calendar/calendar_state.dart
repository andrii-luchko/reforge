part of 'calendar_cubit.dart';

@freezed
sealed class CalendarState with _$CalendarState {
  const CalendarState._();
  const factory CalendarState({
    DateTime? currentDate,
    @Default({}) Map<String, CalendarEntity> calendar,
    @Default(false) bool isLoading,
    String? error,
  }) = _CalendarState;

  Map<DateTime, DayEntity> get currentMonthDays {
    if (currentDate == null) return {};

    return calendar[currentDate!.toYearMonth()]?.days ?? {};
  }
}
