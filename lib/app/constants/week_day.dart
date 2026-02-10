import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum WeekDay {
  monday(1),
  tuesday(2),
  wednesday(3),
  thursday(4),
  friday(5),
  saturday(6),
  sunday(7)
  ;

  const WeekDay(this.value);

  final int value;

  static WeekDay? fromValue(int value) {
    if (value < 1 || value > 7) return null;

    return WeekDay.values[value - 1];
  }
}

extension WeekDayLocalization on WeekDay {
  String label(BuildContext context, {String pattern = 'E'}) {
    final locale = Localizations.localeOf(context).toString();

    final dummyDate = DateTime(2024).add(Duration(days: index));

    return DateFormat(pattern, locale).format(dummyDate);
  }
}

extension WeekDayMapper on List<WeekDay> {
  List<int> toIntList() {
    return map((w) => w.value).toList();
  }
}
