// field_date_picker.dart
import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';

import 'package:table_calendar/table_calendar.dart';

class CalendarDaysView extends StatefulWidget {
  const CalendarDaysView({
    required this.firstDay,
    required this.lastDay,
    required this.focusedDay,
    required this.selectedDay,
    required this.onDaySelected,
    super.key,
  });

  final DateTime firstDay;
  final DateTime lastDay;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  @override
  State<CalendarDaysView> createState() => _CalendarDaysViewState();
}

class _CalendarDaysViewState extends State<CalendarDaysView> {
  late DateTime _focusedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

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

  @override
  Widget build(BuildContext context) {
    return TableCalendar<({DateTime dateTime, bool hasWorkout})>(
      firstDay: widget.firstDay,
      lastDay: widget.lastDay,
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(widget.selectedDay, day),
      calendarFormat: _calendarFormat,
      startingDayOfWeek: StartingDayOfWeek.monday,
      onDaySelected: widget.onDaySelected,
      headerVisible: false,
      onFormatChanged: (format) => setState(() => _calendarFormat = format),
      onPageChanged: (focusedDay) => setState(() => _focusedDay = focusedDay),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
        weekendStyle: subheadH7Medium.copyWith(
          color: context.appTheme.beige700,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        selectedBuilder: (context, day, _) => _buildCell(context, day, isSelected: true),
        todayBuilder: (context, day, _) => _buildCell(context, day, isToday: true),
        defaultBuilder: (context, day, _) => _buildCell(context, day),
        outsideBuilder: (context, day, _) => _buildCell(context, day),
        singleMarkerBuilder: (context, day, event) => _buildCell(context, day),
      ),
    );
  }
}

Widget _buildCell(
  BuildContext context,
  DateTime day, {
  bool isSelected = false,
  bool isToday = false,
}) {
  final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

  var textStyle = subheadH7Medium.copyWith(
    color: isWeekend ? context.appTheme.beige600 : context.appTheme.beige100,
  );

  BoxDecoration? decoration;

  if (isSelected) {
    decoration = BoxDecoration(
      color: context.appTheme.orange500,
      border: GradientBoxBorder(
        gradient: LinearGradient(colors: [context.appTheme.strokeCalendar, Colors.transparent]),
      ),
      borderRadius: BorderRadius.circular(8),
    );
    textStyle = textStyle.copyWith(color: context.appTheme.beige100);
  } else if (isToday) {
    decoration = BoxDecoration(
      border: Border.all(color: context.appTheme.orange500, width: 0.5),
      borderRadius: BorderRadius.circular(8),
    );
  }

  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    alignment: Alignment.center,
    decoration: decoration,
    child: Text('${day.day}', style: textStyle),
  );
}
