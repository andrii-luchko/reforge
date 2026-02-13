import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/calendar/data/models/calendar_data.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';

void main() {
  group('CalendarEntity.fromDto', () {
    test('maps summary fields correctly', () {
      final dto = CalendarData(
        summary: const CalendarSummary(
          totalPlannedInMonth: 20,
          totalCompletedInMonth: 15,
          complianceRate: 75,
        ),
        calendar: [
          CalendarDayDto(
            date: '2025-01-15',
            dayOfWeek: 3,
            isSpecificDay: true,
            isCompleted: true,
            isCanceled: false,
            sessionsCount: 1,
            sessionIds: [1],
          ),
        ],
      );
      final entity = CalendarEntity.fromDto(dto);
      expect(entity.totalPlanned, 20);
      expect(entity.totalCompleted, 15);
      expect(entity.complianceRate, 75);
    });

    test('maps calendar days with normalized dates', () {
      final dto = CalendarData(
        summary: const CalendarSummary(
          totalPlannedInMonth: 1,
          totalCompletedInMonth: 0,
          complianceRate: 0,
        ),
        calendar: [
          CalendarDayDto(
            date: '2025-02-10',
            dayOfWeek: 1,
            isSpecificDay: true,
            isCompleted: false,
            isCanceled: false,
            sessionsCount: 0,
            sessionIds: [],
          ),
        ],
      );
      final entity = CalendarEntity.fromDto(dto);
      expect(entity.days.length, 1);
      expect(entity.days.containsKey(DateTime(2025, 2, 10)), isTrue);
      expect(entity.days[DateTime(2025, 2, 10)]!.date, DateTime(2025, 2, 10));
    });

    test('skips days with invalid date string', () {
      final dto = CalendarData(
        summary: const CalendarSummary(
          totalPlannedInMonth: 1,
          totalCompletedInMonth: 0,
          complianceRate: 0,
        ),
        calendar: [
          CalendarDayDto(
            date: 'invalid-date',
            dayOfWeek: 1,
            isSpecificDay: true,
            isCompleted: false,
            isCanceled: false,
            sessionsCount: 0,
            sessionIds: [],
          ),
        ],
      );
      final entity = CalendarEntity.fromDto(dto);
      expect(entity.days.isEmpty, isTrue);
    });

    test('skips days with null date', () {
      final dto = CalendarData(
        summary: const CalendarSummary(
          totalPlannedInMonth: 1,
          totalCompletedInMonth: 0,
          complianceRate: 0,
        ),
        calendar: [
          CalendarDayDto(
            date: '',
            dayOfWeek: 1,
            isSpecificDay: true,
            isCompleted: false,
            isCanceled: false,
            sessionsCount: 0,
            sessionIds: [],
          ),
        ],
      );
      final entity = CalendarEntity.fromDto(dto);
      expect(entity.days.isEmpty, isTrue);
    });
  });
}
