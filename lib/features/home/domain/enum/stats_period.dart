enum StatsPeriod {
  lastWeek,
  lastMonth,
  lastThreeMonths,
  yearToDate,
  allTime
  ;

  String get label {
    return switch (this) {
      lastWeek => 'Last Week',
      lastMonth => 'Last Month',
      lastThreeMonths => 'Last 3 Months',
      yearToDate => 'Year to Date',
      allTime => 'All Time',
    };
  }

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
