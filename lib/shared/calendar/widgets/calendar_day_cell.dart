import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    required this.day,
    this.isSelected = false,
    this.isToday = false,
    this.event,
    super.key,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final DayEntity? event;

  @override
  Widget build(BuildContext context) {
    if (event != null && event!.isSpecificDay) {
      return _EventDayContent(
        day: day,
        event: event!,
      );
    }

    return _OrdinaryDayContent(
      day: day,
      isSelected: isSelected,
      isToday: isToday,
    );
  }
}

class _EventDayContent extends StatelessWidget {
  const _EventDayContent({
    required this.day,
    required this.event,
  });

  final DateTime day;
  final DayEntity event;

  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    Color textColor;

    if (event.hasSessions) {
      decoration = BoxDecoration(
        color: context.appTheme.orange500,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [context.appTheme.strokeCalendar, Colors.transparent],
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      );
      textColor = context.appTheme.beige100;
    } else {
      decoration = BoxDecoration(
        color: context.appTheme.beige800,
        borderRadius: BorderRadius.circular(8),
      );
      textColor = context.appTheme.beige600;
    }

    return Skeleton.leaf(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: subheadH7Medium.copyWith(color: textColor),
        ),
      ),
    );
  }
}

class _OrdinaryDayContent extends StatelessWidget {
  const _OrdinaryDayContent({
    required this.day,
    required this.isSelected,
    required this.isToday,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    Color textColor = isWeekend ? context.appTheme.beige600 : context.appTheme.beige100;
    BoxDecoration? decoration;

    if (isSelected) {
      decoration = BoxDecoration(
        color: context.appTheme.orange400,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [context.appTheme.strokeCalendar, Colors.transparent],
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      );
      textColor = context.appTheme.beige100;
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: context.appTheme.orange500, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      );
    }

    return Skeleton.leaf(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: subheadH7Medium.copyWith(color: textColor),
        ),
      ),
    );
  }
}
