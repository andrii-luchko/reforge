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

  CalendarEntity? get currentMonth {
    if (currentDate == null) return null;
    return calendar[currentDate!.toYearMonth()];
  }

  Map<DateTime, DayEntity> get currentMonthDays {
    return currentMonth?.days ?? {};
  }
}
