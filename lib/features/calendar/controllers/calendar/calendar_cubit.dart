import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/calendar/data/repository/calendar_repository.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';

part 'calendar_state.dart';
part 'calendar_cubit.freezed.dart';

final firstDay = DateTime(2025);
final DateTime lastDay = DateTime.now().dateOnly.add(const Duration(days: 30));

@injectable
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(this._repository, this._analytics) : super(const CalendarState());

  final CalendarRepository _repository;
  final AnalyticsService _analytics;

  Future<void> initialize() async {
    final currentDate = state.currentDate ?? DateTime.now();

    return changeMonth(currentDate);
  }

  Future<void> changeMonth(DateTime month, {bool forceRefresh = false}) async {
    final monthNormalized = month.toYearMonth();
    unawaited(
      _analytics.logEvent(
        AnalyticsEvents.calendarMonthChange,
        {'month': monthNormalized},
      ),
    );

    if (!forceRefresh && state.calendar.containsKey(monthNormalized)) {
      emit(state.copyWith(currentDate: month));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getMonthCalendarData(month);

    switch (result) {
      case Success(:final value):
        final updatedCalendar = Map<String, CalendarEntity>.from(state.calendar);
        updatedCalendar[monthNormalized] = value;

        emit(
          state.copyWith(
            currentDate: month,
            calendar: updatedCalendar,
            isLoading: false,
          ),
        );

      case Failure(:final error):
        emit(
          state.copyWith(
            currentDate: month,
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  Future<void> refresh() async {
    unawaited(_analytics.logEvent(AnalyticsEvents.calendarRefresh));
    final currentDate = state.currentDate ?? DateTime.now();
    return changeMonth(currentDate, forceRefresh: true);
  }

  void onTrainingDetailsTap() {
    unawaited(_analytics.logEvent(AnalyticsEvents.calendarTrainingDetailsClick));
  }

  void onScheduledTrainingDetailsTap() {
    unawaited(_analytics.logEvent(AnalyticsEvents.scheduledWorkoutDetailsClick));
  }

  DayEntity? navigationCheck(DateTime date) {
    final currentMonthDays = state.visibleMonthDays;
    if (currentMonthDays.isEmpty) return null;

    final day = currentMonthDays[date.dateOnly];

    return day;
  }
}
