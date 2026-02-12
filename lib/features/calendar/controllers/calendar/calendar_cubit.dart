import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/calendar/data/repository/calendar_repository.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';

part 'calendar_state.dart';
part 'calendar_cubit.freezed.dart';

final firstDay = DateTime(2025);
final DateTime lastDay = DateTime.now().dateOnly.add(const Duration(days: 30));

@injectable
class CalendarCubit extends Cubit<CalendarState> {
  CalendarCubit(this._repository) : super(const CalendarState());

  final CalendarRepository _repository;

  Future<void> initialize() async {
    final currentDate = state.currentDate ?? DateTime.now();

    return changeMonth(currentDate);
  }

  Future<void> changeMonth(DateTime month) async {
    final monthNormalized = month.toYearMonth();

    if (state.calendar.containsKey(monthNormalized)) {
      emit(state.copyWith(currentDate: month));
      return;
    }

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getMonthCalendarData(month);

    switch (result) {
      case Success(value: final value):
        final updatedCalendar = Map<String, CalendarEntity>.from(state.calendar);
        updatedCalendar[monthNormalized] = value;

        emit(
          state.copyWith(
            currentDate: month,
            calendar: updatedCalendar,
            isLoading: false,
          ),
        );

      case ErrorR(error: final error):
        emit(
          state.copyWith(
            currentDate: month,
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  DayEntity? navigationCheck(DateTime date) {
    final currentMonthDays = state.currentMonthDays;
    if (currentMonthDays.isEmpty) return null;

    final day = currentMonthDays[date.dateOnly];

    return day;
  }
}
