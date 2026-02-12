// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
import 'package:reforge/shared/calendar/widgets/calendar_day_cell.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarDaysView extends StatefulWidget {
  const CalendarDaysView({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    required this.today,
    this.events = const {},
    this.onPageChanged,
    super.key,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime today;
  final Map<DateTime, DayEntity> events;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime>? onPageChanged;

  @override
  State<CalendarDaysView> createState() => _CalendarDaysViewState();
}

class _CalendarDaysViewState extends State<CalendarDaysView> {
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.focusedDay;
  }

  @override
  void didUpdateWidget(CalendarDaysView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusedDay != widget.focusedDay) {
      _focusedDay = widget.focusedDay;
    }
  }

  Widget _buildDayCell(DateTime day) {
    final event = widget.events[DateUtils.dateOnly(day)];

    final isSelected = widget.selectedDay != null && isSameDay(widget.selectedDay, day);
    final isToday = isSameDay(day, widget.today);

    return CalendarDayCell(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
      event: event,
    );
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<DayEntity>(
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      focusedDay: _focusedDay,

      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: widget.onDaySelected,
      headerVisible: false,

      onPageChanged: (focusedDay) => widget.onPageChanged?.call(focusedDay),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
        weekendStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
      ),
      daysOfWeekHeight: 32,
      rowHeight: 55,
      availableGestures: .horizontalSwipe,
      calendarBuilders: CalendarBuilders(
        disabledBuilder: (context, day, focusedDay) => _buildDayCell(day),
        selectedBuilder: (context, day, focusedDay) => _buildDayCell(day),
        todayBuilder: (context, day, focusedDay) => _buildDayCell(day),
        defaultBuilder: (context, day, focusedDay) => _buildDayCell(day),
        outsideBuilder: (context, day, focusedDay) => _buildDayCell(day),
      ),
    );
  }
}
