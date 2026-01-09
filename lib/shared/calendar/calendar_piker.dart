// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:reforge/shared/calendar/enum/calendar_view_mode.dart';
import 'package:reforge/shared/calendar/widgets/calendar_days_view.dart';
import 'package:reforge/shared/calendar/widgets/calendar_header.dart';
import 'package:reforge/shared/calendar/widgets/calendar_month_view.dart';
import 'package:reforge/shared/calendar/widgets/calendar_years_view.dart';

class CalendarPicker extends StatefulWidget {
  const CalendarPicker({
    required this.initialDate,
    required this.firstDay,
    required this.lastDay,
    required this.onDateSelected,
    this.needBottomLine = true,
    this.headerTitle,
    super.key,
  });

  final String? headerTitle;
  final bool needBottomLine;
  final DateTime initialDate;
  final DateTime firstDay;
  final DateTime lastDay;
  final ValueChanged<DateTime> onDateSelected;

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  CalendarViewMode _viewMode = CalendarViewMode.days;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialDate;
    _selectedDay = widget.initialDate;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    widget.onDateSelected(selectedDay);
  }

  void _onPrevious() {
    setState(() {
      _focusedDay = switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month - 1),
        CalendarViewMode.months => DateTime(_focusedDay.year - 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year - 10, _focusedDay.month),
      };
    });
  }

  void _onNext() {
    setState(() {
      _focusedDay = switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month + 1),
        CalendarViewMode.months => DateTime(_focusedDay.year + 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year + 10, _focusedDay.month),
      };
    });
  }

  void _onHeaderTap() {
    setState(() {
      _viewMode = switch (_viewMode) {
        CalendarViewMode.days => CalendarViewMode.months,
        CalendarViewMode.months => CalendarViewMode.years,
        CalendarViewMode.years => CalendarViewMode.days,
      };
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, month);
    });
  }

  void _onYearSelected(int year) {
    setState(() {
      _focusedDay = DateTime(year, _focusedDay.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CalendarHeader(
          needBottomLine: widget.needBottomLine,
          headerTitle: widget.headerTitle,
          focusedDay: _focusedDay,
          viewMode: _viewMode,
          onHeaderTap: _onHeaderTap,
          onPrevious: _onPrevious,
          onNext: _onNext,
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: switch (_viewMode) {
            CalendarViewMode.days => CalendarDaysView(
              key: const ValueKey('days_view'),
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              focusedDay: _focusedDay,
              selectedDay: _selectedDay,
              onDaySelected: _onDaySelected,
            ),
            CalendarViewMode.months => CalendarMonthsView(
              key: const ValueKey('months_view'),
              focusedDay: _focusedDay,
              onMonthSelected: _onMonthSelected,
            ),
            CalendarViewMode.years => CalendarYearsView(
              key: const ValueKey('years_view'),
              focusedDay: _focusedDay,
              onYearSelected: _onYearSelected,
            ),
          },
        ),
      ],
    );
  }
}
