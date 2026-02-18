import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/home/controller/cubit/home_cubit.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../../../helpers/test_setup.dart';
import '../mocks/mock_home_repository.dart';

OnboardedUser createTestOnboardedUser({int factionId = 1}) {
  return User.onboarded(
    id: 1,
    email: 'test@example.com',
    bodyWeight: 70,
    measurementSystem: MeasurementSystem.metric,
    factionId: factionId,
    secondaryFactionId: 2,
    birthDate: DateTime(1990, 1, 15),
    workoutsPerWeek: 3,
    userName: 'TestUser',
  ) as OnboardedUser;
}

UserStats createTestUserStats() => UserStatsX.mock();

void main() {
  late MockHomeRepository mockRepository;
  late MockAnalyticsService mockAnalytics;

  setUpAll(() {
    initTestTranslations();
    registerFallbackValue(StatsPeriod.lastWeek);
  });

  setUp(() {
    mockRepository = MockHomeRepository();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
  });

  group('HomeCubit', () {
    group('loadInitialData', () {
      test('Success emits user, statsMap, rank, isLoading false', () async {
        final user = createTestOnboardedUser();
        final stats = createTestUserStats();
        when(() => mockRepository.getUserData()).thenReturn(user);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        expect(cubit.state.user, user);
        expect(cubit.state.statsMap[StatsPeriod.lastWeek], stats);
        expect(cubit.state.rank, isNotNull);
        expect(cubit.state.rank!.lvl, stats.level);
        expect(cubit.state.rank!.xp, stats.currentXp);
        expect(cubit.state.rank!.maxXp, stats.totalXp);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
      });

      test('partial: getUserData null, getUserStats Success emits statsMap with Faction.gakki fallback', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        expect(cubit.state.user, isNull);
        expect(cubit.state.statsMap[StatsPeriod.lastWeek], stats);
        expect(cubit.state.rank, isNotNull);
        expect(cubit.state.rank!.faction, Faction.gakki);
        expect(cubit.state.isLoading, false);
      });

      test('Error emits error and isLoading false', () async {
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isLoading, false);
      });
    });

    group('loadStatsByPeriod', () {
      test('cache hit does not call repository', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        await cubit.loadStatsByPeriod(StatsPeriod.lastWeek);

        verify(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).called(1);
      });

      test('cache miss Success emits statsMap and rank', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.success(stats));
        when(() => mockRepository.getUserStats(StatsPeriod.lastMonth))
            .thenAnswer((_) async => Result.success(UserStatsX.mock(level: 6)));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        await cubit.loadStatsByPeriod(StatsPeriod.lastMonth);

        expect(cubit.state.statsMap[StatsPeriod.lastMonth], isNotNull);
        expect(cubit.state.statsMap[StatsPeriod.lastMonth]!.level, 6);
        expect(cubit.state.period, StatsPeriod.lastMonth);
        expect(cubit.state.isStatsLoading, false);
      });

      test('cache miss Error emits error and isStatsLoading false', () async {
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadStatsByPeriod(StatsPeriod.lastWeek);

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isStatsLoading, false);
      });
    });

    group('changePeriod', () {
      test('calls loadStatsByPeriod with period', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserData()).thenReturn(null);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek))
            .thenAnswer((_) async => Result.success(stats));
        when(() => mockRepository.getUserStats(StatsPeriod.yearToDate))
            .thenAnswer((_) async => Result.success(UserStatsX.mock(level: 7)));

        final cubit = HomeCubit(mockRepository, mockAnalytics);
        await cubit.loadInitialData();

        cubit.changePeriod(StatsPeriod.yearToDate);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.period, StatsPeriod.yearToDate);
        expect(cubit.state.statsMap[StatsPeriod.yearToDate]!.level, 7);
      });
    });
  });

  group('HomeState', () {
    group('currentStats', () {
      test('returns statsMap value for current period', () {
        final stats = createTestUserStats();
        const state = HomeState(
          
        );
        final stateWithStats = state.copyWith(
          statsMap: {StatsPeriod.lastWeek: stats},
        );
        expect(stateWithStats.currentStats, stats);
      });

      test('returns null when period not in statsMap', () {
        const state = HomeState(
          period: StatsPeriod.lastMonth,
        );
        expect(state.currentStats, isNull);
      });
    });
  });
}
