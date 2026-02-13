import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/extensions/date_time_extensions.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/calendar/controllers/calendar/calendar_cubit.dart';
import 'package:reforge/features/calendar/domain/entity/calendar_entity.dart';
import '../mocks/mock_calendar_repository.dart';

CalendarEntity createTestCalendarEntity({Map<DateTime, DayEntity>? days}) {
  return CalendarEntity(
    totalPlanned: 10,
    totalCompleted: 5,
    complianceRate: 50,
    days: days ?? {},
  );
}

DayEntity createTestDayEntity(DateTime date, {List<int> sessionIds = const []}) {
  return DayEntity(
    date: date,
    isCompleted: false,
    isCanceled: false,
    isSpecificDay: true,
    sessionsCount: sessionIds.length,
    sessionIds: sessionIds,
  );
}

void main() {
  late MockCalendarRepository mockRepository;

  setUp(() {
    mockRepository = MockCalendarRepository();
  });

  group('CalendarCubit', () {
    group('initialize', () {
      blocTest<CalendarCubit, CalendarState>(
        'calls changeMonth and loads data',
        build: () {
          when(() => mockRepository.getMonthCalendarData(any())).thenAnswer(
            (_) async => Result.success(createTestCalendarEntity()),
          );
          return CalendarCubit(mockRepository);
        },
        act: (cubit) => cubit.initialize(),
        expect: () => [
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
          isA<CalendarState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.currentDate, 'currentDate', isNotNull)
              .having((s) => s.calendar, 'calendar', isNotEmpty),
        ],
      );
    });

    group('changeMonth', () {
      test('cache hit does not call repository', () async {
        final monthKey = DateTime(2025, 3, 15).toYearMonth();
        final cubit = CalendarCubit(mockRepository);
        await (cubit
          ..emit(CalendarState(
            currentDate: DateTime(2025, 3),
            calendar: {monthKey: createTestCalendarEntity()},
          ))).changeMonth(DateTime(2025, 3, 15));
        expect(cubit.state.currentDate, DateTime(2025, 3, 15));
        verifyNever(() => mockRepository.getMonthCalendarData(any()));
      });

      blocTest<CalendarCubit, CalendarState>(
        'cache miss and Success emits calendar with new data',
        build: () {
          when(() => mockRepository.getMonthCalendarData(any())).thenAnswer(
            (_) async => Result.success(
              createTestCalendarEntity(days: {
                DateTime(2025, 4): createTestDayEntity(DateTime(2025, 4)),
              }),
            ),
          );
          return CalendarCubit(mockRepository);
        },
        act: (cubit) => cubit.changeMonth(DateTime(2025, 4, 15)),
        expect: () => [
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
          isA<CalendarState>()
              .having((s) => s.currentDate, 'currentDate', DateTime(2025, 4, 15))
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.calendar['2025-04'], 'calendar[2025-04]', isNotNull),
        ],
      );

      blocTest<CalendarCubit, CalendarState>(
        'cache miss and ErrorR emits error',
        build: () {
          when(() => mockRepository.getMonthCalendarData(any())).thenAnswer(
            (_) async => Result.error(Exception('Network error')),
          );
          return CalendarCubit(mockRepository);
        },
        act: (cubit) => cubit.changeMonth(DateTime(2025, 5, 15)),
        expect: () => [
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
          isA<CalendarState>()
              .having((s) => s.isLoading, 'isLoading', false)
              .having((s) => s.error, 'error', isNotNull),
        ],
      );

      blocTest<CalendarCubit, CalendarState>(
        'forceRefresh always calls repository',
        build: () {
          when(() => mockRepository.getMonthCalendarData(any())).thenAnswer(
            (_) async => Result.success(createTestCalendarEntity()),
          );
          return CalendarCubit(mockRepository);
        },
        seed: () {
          final month = DateTime(2025, 6, 15);
          return CalendarState(
            currentDate: month,
            calendar: {month.toYearMonth(): createTestCalendarEntity()},
          );
        },
        act: (cubit) => cubit.changeMonth(DateTime(2025, 6, 15), forceRefresh: true),
        expect: () => [
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', false),
        ],
      );
    });

    group('refresh', () {
      blocTest<CalendarCubit, CalendarState>(
        'calls changeMonth with forceRefresh',
        build: () {
          when(() => mockRepository.getMonthCalendarData(any())).thenAnswer(
            (_) async => Result.success(createTestCalendarEntity()),
          );
          return CalendarCubit(mockRepository);
        },
        seed: () => CalendarState(currentDate: DateTime(2025, 7, 15)),
        act: (cubit) => cubit.refresh(),
        expect: () => [
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', true),
          isA<CalendarState>().having((s) => s.isLoading, 'isLoading', false),
        ],
      );
    });

    group('navigationCheck', () {
      test('returns DayEntity when date exists in currentMonthDays', () {
        final date = DateTime(2025, 8, 15);
        final dayEntity = createTestDayEntity(date, sessionIds: [1, 2]);
        final cubit = CalendarCubit(mockRepository);
        expect(
          (cubit
            ..emit(CalendarState(
              currentDate: DateTime(2025, 8),
              calendar: {
                '2025-08': CalendarEntity(
                  totalPlanned: 1,
                  totalCompleted: 0,
                  complianceRate: 0,
                  days: {date: dayEntity},
                ),
              },
            ))).navigationCheck(date),
          dayEntity,
        );
      });

      test('returns null when currentMonthDays is empty', () {
        final cubit = CalendarCubit(mockRepository);
        expect(
          (cubit..emit(const CalendarState())).navigationCheck(DateTime(2025, 9, 15)),
          isNull,
        );
      });

      test('returns null when currentDate is null', () {
        final cubit = CalendarCubit(mockRepository);
        expect(
          (cubit..emit(const CalendarState())).navigationCheck(DateTime(2025, 9, 15)),
          isNull,
        );
      });

      test('returns null when date not in currentMonthDays', () {
        final date = DateTime(2025, 10, 15);
        final otherDate = DateTime(2025, 10, 20);
        final cubit = CalendarCubit(mockRepository);
        expect(
          (cubit
            ..emit(CalendarState(
              currentDate: DateTime(2025, 10),
              calendar: {
                '2025-10': CalendarEntity(
                  totalPlanned: 1,
                  totalCompleted: 0,
                  complianceRate: 0,
                  days: {otherDate: createTestDayEntity(otherDate)},
                ),
              },
            ))).navigationCheck(date),
          isNull,
        );
      });
    });

    group('CalendarState getters', () {
      test('currentMonth returns null when currentDate is null', () {
        final state = CalendarState(
          calendar: {'2025-01': createTestCalendarEntity()},
        );
        expect(state.currentMonth, isNull);
      });

      test('currentMonthDays returns empty when currentMonth is null', () {
        const state = CalendarState();
        expect(state.currentMonthDays, isEmpty);
      });

      test('currentMonth returns entity when currentDate matches calendar key', () {
        final entity = createTestCalendarEntity();
        final state = CalendarState(
          currentDate: DateTime(2025, 2, 15),
          calendar: {'2025-02': entity},
        );
        expect(state.currentMonth, entity);
      });

      test('currentMonthDays returns days from currentMonth', () {
        final days = {
          DateTime(2025, 3): createTestDayEntity(DateTime(2025, 3)),
        };
        final entity = createTestCalendarEntity(days: days);
        final state = CalendarState(
          currentDate: DateTime(2025, 3, 15),
          calendar: {'2025-03': entity},
        );
        expect(state.currentMonthDays, days);
      });
    });
  });
}
