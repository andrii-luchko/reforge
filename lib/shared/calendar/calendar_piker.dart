// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
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
    this.events = const {},
    this.selectedDate,
    this.onFocusedDayChanged,
    super.key,
  });

  final String? headerTitle;
  final bool needBottomLine;
  final DateTime initialDate;
  final DateTime? selectedDate;
  final DateTime firstDay;
  final DateTime lastDay;
  final Map<DateTime, DayEntity> events;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime>? onFocusedDayChanged;

  @override
  State<CalendarPicker> createState() => _CalendarPickerState();
}

class _CalendarPickerState extends State<CalendarPicker> {
  late DateTime _focusedDay;

  CalendarViewMode _viewMode = CalendarViewMode.days;

  DateTime _clampFocusedDay(DateTime day) {
    final dateOnly = DateUtils.dateOnly(day);
    final first = DateUtils.dateOnly(widget.firstDay);
    final last = DateUtils.dateOnly(widget.lastDay);
    if (dateOnly.isBefore(first)) return first;
    if (dateOnly.isAfter(last)) return last;
    return dateOnly;
  }

  void _updateFocusedDay(DateTime day) {
    final clamped = _clampFocusedDay(day);
    if (_focusedDay != clamped) {
      setState(() => _focusedDay = clamped);
      widget.onFocusedDayChanged?.call(_focusedDay);
    }
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = _clampFocusedDay(widget.initialDate);
  }

  @override
  void didUpdateWidget(CalendarPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.firstDay != widget.firstDay || oldWidget.lastDay != widget.lastDay) {
      _focusedDay = _clampFocusedDay(_focusedDay);
    }
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    widget.onDateSelected(selectedDay);
  }

  void _onPrevious() {
    setState(() {
      _focusedDay = _clampFocusedDay(switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month - 1),
        CalendarViewMode.months => DateTime(_focusedDay.year - 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year - 10, _focusedDay.month),
      });
    });
    widget.onFocusedDayChanged?.call(_focusedDay);
  }

  void _onNext() {
    setState(() {
      _focusedDay = _clampFocusedDay(switch (_viewMode) {
        CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month + 1),
        CalendarViewMode.months => DateTime(_focusedDay.year + 1, _focusedDay.month),
        CalendarViewMode.years => DateTime(_focusedDay.year + 10, _focusedDay.month),
      });
    });
    widget.onFocusedDayChanged?.call(_focusedDay);
  }

  void _onHeaderTap() {
    setState(() {
      _viewMode = switch (_viewMode) {
        CalendarViewMode.days => CalendarViewMode.months,
        CalendarViewMode.months => CalendarViewMode.years,
        CalendarViewMode.years => CalendarViewMode.days,
      };
      _focusedDay = _clampFocusedDay(_focusedDay);
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      _focusedDay = _clampFocusedDay(DateTime(_focusedDay.year, month));
    });
    widget.onFocusedDayChanged?.call(_focusedDay);
  }

  void _onYearSelected(int year) {
    setState(() {
      _focusedDay = _clampFocusedDay(DateTime(year, _focusedDay.month));
    });
    widget.onFocusedDayChanged?.call(_focusedDay);
  }

  DateTime get _prevDate => switch (_viewMode) {
    CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month - 1),
    CalendarViewMode.months => DateTime(_focusedDay.year - 1, _focusedDay.month),
    CalendarViewMode.years => DateTime(_focusedDay.year - 10, _focusedDay.month),
  };

  DateTime get _nextDate => switch (_viewMode) {
    CalendarViewMode.days => DateTime(_focusedDay.year, _focusedDay.month + 1),
    CalendarViewMode.months => DateTime(_focusedDay.year + 1, _focusedDay.month),
    CalendarViewMode.years => DateTime(_focusedDay.year + 10, _focusedDay.month),
  };

  @override
  Widget build(BuildContext context) {
    final first = DateUtils.dateOnly(widget.firstDay);
    final last = DateUtils.dateOnly(widget.lastDay);
    final canGoPrevious = !DateUtils.dateOnly(_prevDate).isBefore(first);
    final canGoNext = !DateUtils.dateOnly(_nextDate).isAfter(last);

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
          canGoPrevious: canGoPrevious,
          canGoNext: canGoNext,
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
              selectedDay: widget.selectedDate,
              today: widget.initialDate,
              onDaySelected: _onDaySelected,
              events: widget.events,
              onPageChanged: _updateFocusedDay,
            ),
            CalendarViewMode.months => CalendarMonthsView(
              key: const ValueKey('months_view'),
              focusedDay: _focusedDay,
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              onMonthSelected: _onMonthSelected,
            ),
            CalendarViewMode.years => CalendarYearsView(
              key: const ValueKey('years_view'),
              focusedDay: _focusedDay,
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              onYearSelected: _onYearSelected,
            ),
          },
        ),
      ],
    );
  }
}
