import 'dart:async';

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
import '../../../core/user/mocks/mock_user_cubit.dart';
import '../../../helpers/test_setup.dart';
import '../mocks/mock_home_repository.dart';

OnboardedUser createTestOnboardedUser({int factionId = 1, String userName = 'TestUser'}) {
  return User.onboarded(
        id: 1,
        email: 'test@example.com',
        bodyWeight: 70,
        measurementSystem: MeasurementSystem.metric,
        factionId: factionId,
        secondaryFactionId: 2,
        birthDate: DateTime(1990, 1, 15),
        workoutsPerWeek: 3,
        userName: userName,
      )
      as OnboardedUser;
}

UserStats createTestUserStats() => UserStatsX.mock();

void main() {
  late MockHomeRepository mockRepository;
  late MockAnalyticsService mockAnalytics;
  late MockUserCubit mockUserCubit;

  setUpAll(() {
    initTestTranslations();
    registerFallbackValue(StatsPeriod.lastWeek);
  });

  setUp(() {
    mockRepository = MockHomeRepository();
    mockAnalytics = MockAnalyticsService();
    mockUserCubit = MockUserCubit();
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
    when(() => mockUserCubit.currentOnboardedUser).thenReturn(null);
    when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => const Stream.empty());
  });

  group('HomeCubit', () {
    group('loadInitialData', () {
      test('Success emits user, statsMap, rank, isLoading false', () async {
        final user = createTestOnboardedUser();
        final stats = createTestUserStats();
        when(() => mockUserCubit.currentOnboardedUser).thenReturn(user);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        expect(cubit.state.user, user);
        expect(cubit.state.statsMap[StatsPeriod.lastWeek], stats);
        expect(cubit.state.rank, isNotNull);
        expect(cubit.state.rank!.lvl, stats.level);
        expect(cubit.state.rank!.xp, stats.currentXp);
        expect(cubit.state.rank!.maxXp, stats.xpGoal);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
      });

      test('partial: no user keeps rank empty even when stats succeed', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        expect(cubit.state.user, isNull);
        expect(cubit.state.statsMap[StatsPeriod.lastWeek], stats);
        expect(cubit.state.rank, isNull);
        expect(cubit.state.isLoading, false);
      });

      test('Error emits error and isLoading false', () async {
        when(
          () => mockRepository.getUserStats(StatsPeriod.lastWeek),
        ).thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isLoading, false);
      });
    });

    group('loadStatsByPeriod', () {
      test('cache hit does not call repository', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        await cubit.loadStatsByPeriod(StatsPeriod.lastWeek);

        verify(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).called(1);
      });

      test('cache miss Success emits statsMap and rank', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));
        when(
          () => mockRepository.getUserStats(StatsPeriod.lastMonth),
        ).thenAnswer((_) async => Result.success(UserStatsX.mock(level: 6)));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        await cubit.loadStatsByPeriod(StatsPeriod.lastMonth);

        expect(cubit.state.statsMap[StatsPeriod.lastMonth], isNotNull);
        expect(cubit.state.statsMap[StatsPeriod.lastMonth]!.level, 6);
        expect(cubit.state.period, StatsPeriod.lastMonth);
        expect(cubit.state.isStatsLoading, false);
      });

      test('cache miss Error preserves the last valid rank', () async {
        final user = createTestOnboardedUser();
        final stats = createTestUserStats();
        when(() => mockUserCubit.currentOnboardedUser).thenReturn(user);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));
        when(
          () => mockRepository.getUserStats(StatsPeriod.lastMonth),
        ).thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();
        final validRank = cubit.state.rank;
        await cubit.loadStatsByPeriod(StatsPeriod.lastMonth);

        expect(cubit.state.error, isNotNull);
        expect(cubit.state.isStatsLoading, false);
        expect(cubit.state.rank, same(validRank));
      });

      test('refresh after workout bypasses and replaces cached stats', () async {
        final user = createTestOnboardedUser();
        final initialStats = createTestUserStats();
        final refreshedStats = UserStatsX.mock(level: 8);
        var calls = 0;
        when(() => mockUserCubit.currentOnboardedUser).thenReturn(user);
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async {
          calls++;
          return Result.success(calls == 1 ? initialStats : refreshedStats);
        });

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();
        await cubit.refreshAfterWorkout();

        expect(cubit.state.currentStats, same(refreshedStats));
        expect(cubit.state.rank?.lvl, 8);
        verify(
          () => mockRepository.getUserStats(StatsPeriod.lastWeek),
        ).called(2);
      });
    });

    group('changePeriod', () {
      test('calls loadStatsByPeriod with period', () async {
        final stats = createTestUserStats();
        when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));
        when(
          () => mockRepository.getUserStats(StatsPeriod.yearToDate),
        ).thenAnswer((_) async => Result.success(UserStatsX.mock(level: 7)));

        final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
        await cubit.loadInitialData();

        cubit.changePeriod(StatsPeriod.yearToDate);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.period, StatsPeriod.yearToDate);
        expect(cubit.state.statsMap[StatsPeriod.yearToDate]!.level, 7);
      });
    });

    test('name change updates the user without rebuilding rank or reloading stats', () async {
      final changes = StreamController<OnboardedUser?>.broadcast();
      final initialUser = createTestOnboardedUser();
      final stats = createTestUserStats();
      when(() => mockUserCubit.currentOnboardedUser).thenReturn(initialUser);
      when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => changes.stream);
      when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));

      final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
      await cubit.loadInitialData();
      final validRank = cubit.state.rank;
      final updatedUser = initialUser.copyWith(userName: 'Updated');
      changes.add(updatedUser);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.user, updatedUser);
      expect(cubit.state.rank, same(validRank));
      verify(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).called(1);

      await cubit.close();
      await changes.close();
    });

    test('faction change preserves rank progress without reloading stats and clears on logout', () async {
      final changes = StreamController<OnboardedUser?>.broadcast();
      final initialUser = createTestOnboardedUser();
      final stats = createTestUserStats();
      when(() => mockUserCubit.currentOnboardedUser).thenReturn(initialUser);
      when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => changes.stream);
      when(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).thenAnswer((_) async => Result.success(stats));

      final cubit = HomeCubit(mockRepository, mockAnalytics, mockUserCubit);
      await cubit.loadInitialData();
      final validRank = cubit.state.rank!;
      final updatedUser = initialUser.copyWith(factionId: Faction.gyohyo.id);
      changes.add(updatedUser);
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.rank?.faction, Faction.gyohyo);
      expect(cubit.state.rank?.lvl, validRank.lvl);
      expect(cubit.state.rank?.xp, validRank.xp);
      expect(cubit.state.rank?.maxXp, validRank.maxXp);
      verify(() => mockRepository.getUserStats(StatsPeriod.lastWeek)).called(1);

      changes.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, const HomeState());

      await cubit.close();
      await changes.close();
    });
  });

  group('HomeState', () {
    group('currentStats', () {
      test('returns statsMap value for current period', () {
        final stats = createTestUserStats();
        const state = HomeState();
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
