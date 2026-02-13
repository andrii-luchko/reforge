import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/calendar/data/models/calendar_data.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';

void main() {
  group('DayEntity', () {
    group('hasSessions', () {
      test('returns true when sessionIds is not empty', () {
        final entity = DayEntity(
          date: DateTime(2025, 1, 15),
          isCompleted: false,
          isCanceled: false,
          isSpecificDay: true,
          sessionsCount: 1,
          sessionIds: [1, 2],
        );
        expect(entity.hasSessions, isTrue);
      });

      test('returns false when sessionIds is empty', () {
        final entity = DayEntity(
          date: DateTime(2025, 1, 15),
          isCompleted: false,
          isCanceled: false,
          isSpecificDay: true,
          sessionsCount: 0,
          sessionIds: [],
        );
        expect(entity.hasSessions, isFalse);
      });
    });

    group('latestSessionId', () {
      test('returns null when sessionIds is empty', () {
        final entity = DayEntity(
          date: DateTime(2025, 1, 15),
          isCompleted: false,
          isCanceled: false,
          isSpecificDay: true,
          sessionsCount: 0,
          sessionIds: [],
        );
        expect(entity.latestSessionId, isNull);
      });

      test('returns max sessionId when sessionIds has values', () {
        final entity = DayEntity(
          date: DateTime(2025, 1, 15),
          isCompleted: false,
          isCanceled: false,
          isSpecificDay: true,
          sessionsCount: 3,
          sessionIds: [1, 5, 3],
        );
        expect(entity.latestSessionId, 5);
      });

      test('returns single sessionId when only one', () {
        final entity = DayEntity(
          date: DateTime(2025, 1, 15),
          isCompleted: false,
          isCanceled: false,
          isSpecificDay: true,
          sessionsCount: 1,
          sessionIds: [42],
        );
        expect(entity.latestSessionId, 42);
      });
    });

    group('fromDto', () {
      test('maps CalendarDayDto to DayEntity', () {
        final dto = CalendarDayDto(
          date: '2025-03-20',
          dayOfWeek: 4,
          isSpecificDay: true,
          isCompleted: true,
          isCanceled: false,
          sessionsCount: 2,
          sessionIds: [10, 20],
        );
        final entity = DayEntity.fromDto(dto);
        expect(entity.date, DateTime(2025, 3, 20));
        expect(entity.isSpecificDay, true);
        expect(entity.isCompleted, true);
        expect(entity.isCanceled, false);
        expect(entity.sessionsCount, 2);
        expect(entity.sessionIds, [10, 20]);
      });

      test('uses epoch when date string is invalid', () {
        final dto = CalendarDayDto(
          date: 'invalid',
          dayOfWeek: 1,
          isSpecificDay: false,
          isCompleted: false,
          isCanceled: false,
          sessionsCount: 0,
          sessionIds: [],
        );
        final entity = DayEntity.fromDto(dto);
        expect(entity.date, DateTime(1970));
      });
    });
  });
}
