// ignore_for_file: sort_constructors_first

import 'package:reforge/features/calendar/data/models/calendar_data.dart';

class CalendarEntity {
  CalendarEntity({
    required this.totalPlanned,
    required this.totalCompleted,
    required this.complianceRate,

    required this.days,
  });

  final int totalPlanned;
  final int totalCompleted;
  final int complianceRate;
  final Map<DateTime, DayEntity> days;

  factory CalendarEntity.fromDto(CalendarData dto) {
    // ignore: omit_local_variable_types
    final Map<DateTime, DayEntity> daysMap = {};

    for (final dayDto in dto.calendar) {
      final normalized = _normalizeDate(dayDto.date);
      if (normalized != null) {
        daysMap[normalized] = DayEntity.fromDto(dayDto);
      }
    }
    return CalendarEntity(
      totalPlanned: dto.summary.totalPlannedInMonth,
      totalCompleted: dto.summary.totalCompletedInMonth,
      complianceRate: dto.summary.complianceRate,
      days: daysMap,
    );
  }
  static DateTime? _normalizeDate(String? dateString) {
    if (dateString == null) return null;
    final date = DateTime.tryParse(dateString);
    if (date == null) return null;
    return DateTime(date.year, date.month, date.day);
  }
}

class DayEntity {
  DayEntity({
    required this.date,
    required this.isCompleted,

    required this.sessionsCount,
    required this.sessionIds,
    required this.isCanceled,
    required this.scheduledWorkoutDayId,
    required this.isSpecificDay,
  });

  final DateTime date;
  final bool isSpecificDay;
  final bool isCompleted;
  final bool isCanceled;

  final int sessionsCount;
  final int? scheduledWorkoutDayId;
  final List<int> sessionIds;

  factory DayEntity.fromDto(CalendarDayDto dto) {
    final parsedDate = DateTime.tryParse(dto.date) ?? DateTime(1970);

    return DayEntity(
      date: parsedDate,
      isCompleted: dto.isCompleted,
      isCanceled: dto.isCanceled,
      isSpecificDay: dto.isSpecificDay,
      scheduledWorkoutDayId: dto.scheduledWorkoutDayId,
      sessionIds: dto.sessionIds,
      sessionsCount: dto.sessionsCount,
    );
  }

  bool get hasSessions {
    return sessionIds.isNotEmpty;
  }

  int? get latestSessionId {
    return sessionIds.isEmpty ? null : sessionIds.reduce((curr, next) => curr > next ? curr : next);
  }

  @override
  String toString() {
    return 'DayEntity(date: $date, isSpecificDay: $isSpecificDay, isCompleted: $isCompleted, isCanceled: $isCanceled, sessionsCount: $sessionsCount, scheduledWorkoutDayId: $scheduledWorkoutDayId, sessionIds: $sessionIds)';
  }
}
