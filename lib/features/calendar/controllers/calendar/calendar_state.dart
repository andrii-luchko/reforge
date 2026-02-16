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

  Map<DateTime, DayEntity> get visibleMonthDays {
    if (currentDate == null) return {};

    final current = currentMonth?.days ?? {};
    final prevKey = DateTime(currentDate!.year, currentDate!.month - 1).toYearMonth();
    final nextKey = DateTime(currentDate!.year, currentDate!.month + 1).toYearMonth();
    final prev = calendar[prevKey]?.days ?? {};
    final next = calendar[nextKey]?.days ?? {};

    return {...prev, ...current, ...next};
  }
}
