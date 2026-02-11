import 'package:reforge/generated/i18n/translations.g.dart';

enum StatsPeriod {
  lastWeek,
  lastMonth,
  lastThreeMonths,
  yearToDate,
  allTime
  ;

  ({DateTime start, DateTime end}) get range {
    final now = DateTime.now().toUtc();
    final today = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return switch (this) {
      lastWeek => (
        start: today.subtract(const Duration(days: 7)),
        end: today,
      ),
      lastMonth => (
        start: today.subtract(const Duration(days: 30)),
        end: today,
      ),
      lastThreeMonths => (
        start: today.subtract(const Duration(days: 90)),
        end: today,
      ),
      yearToDate => (
        start: DateTime(
          now.year,
        ).toUtc(),
        end: today,
      ),
      allTime => (
        start: DateTime(
          2024,
        ).toUtc(),
        end: today,
      ),
    };
  }
}

extension StatsPeriodExtension on StatsPeriod {
  String label(Translations t) {
    return switch (this) {
      StatsPeriod.lastWeek => t.home.stats_period.last_week,
      StatsPeriod.lastMonth => t.home.stats_period.last_month,
      StatsPeriod.lastThreeMonths => t.home.stats_period.last_three_months,
      StatsPeriod.yearToDate => t.home.stats_period.year_to_date,
      StatsPeriod.allTime => t.home.stats_period.all_time,
    };
  }
}
