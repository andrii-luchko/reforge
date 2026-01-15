import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/theme/typography_theme.dart';
import 'package:reforge/shared/calendar/widgets/calendar_days_view.dart';
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
  final CalendarEvent? event;
  @override
  Widget build(BuildContext context) {
    final isWeekend = day.weekday == DateTime.saturday || day.weekday == DateTime.sunday;

    var textStyle = subheadH7Medium.copyWith(
      color: isWeekend ? context.appTheme.beige600 : context.appTheme.beige100,
    );

    BoxDecoration? decoration;

    if (isSelected) {
      decoration = BoxDecoration(
        color: context.appTheme.orange500,
        border: GradientBoxBorder(
          gradient: LinearGradient(
            colors: [context.appTheme.strokeCalendar, Colors.transparent],
          ),
        ),
        borderRadius: BorderRadius.circular(8),
      );
    } else if (isToday) {
      decoration = BoxDecoration(
        border: Border.all(color: context.appTheme.orange500, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      );
    }

    if (event != null) {
      decoration = event!.hasWorkout
          ? BoxDecoration(
              color: context.appTheme.orange500,
              border: GradientBoxBorder(
                gradient: LinearGradient(
                  colors: [context.appTheme.strokeCalendar, Colors.transparent],
                ),
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : BoxDecoration(
              color: context.appTheme.beige800,
              borderRadius: BorderRadius.circular(8),
            );

      textStyle = textStyle.copyWith(color: event!.hasWorkout ? context.appTheme.beige100 : context.appTheme.beige600);
    }

    return Skeleton.leaf(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        alignment: Alignment.center,
        decoration: decoration,
        child: Text(
          '${day.day}',
          style: textStyle,
        ),
      ),
    );
  }
}
