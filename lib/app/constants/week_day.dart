import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum WeekDay { monday, tuesday, wednesday, thursday, friday, saturday, sunday }

extension WeekDayLocalization on WeekDay {
  int get value {
    switch (this) {
      case WeekDay.monday:
        return 1;
      case WeekDay.tuesday:
        return 2;
      case WeekDay.wednesday:
        return 3;
      case WeekDay.thursday:
        return 4;
      case WeekDay.friday:
        return 5;
      case WeekDay.saturday:
        return 6;
      case WeekDay.sunday:
        return 7;
    }
  }

  static WeekDay fromValue(int value) {
    return WeekDay.values.firstWhere((day) => day.value == value);
  }

  String label(BuildContext context, {String pattern = 'E'}) {
    final locale = Localizations.localeOf(context).toString();

    final dummyDate = DateTime(
      2024,
    ).add(Duration(days: index));

    return DateFormat(pattern, locale).format(dummyDate);
  }
}
