import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../../../core/user/mocks/mock_user_cubit.dart';
import '../mocks/mock_leaderboard_repository.dart';

ImmortalForgeEntity createTestImmortalForgeEntity({
  int userId = 1,
  String email = 'test@test.com',
  int score = 100,
  int rank = 1,
  String title = 'Daizōshō',
}) {
  return ImmortalForgeEntity(
    userId: userId,
    email: email,
    score: score,
    rank: rank,
    title: title,
  );
}

OnboardedUser createTestUser(Faction faction) => OnboardedUser(
  id: 1,
  measurementSystem: MeasurementSystem.metric,
  factionId: faction.id,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
);

void main() {
  late MockLeaderboardRepository mockRepository;
  late MockAnalyticsService mockAnalytics;
  late MockUserCubit mockUserCubit;

  setUp(() {
    mockRepository = MockLeaderboardRepository();
    mockAnalytics = MockAnalyticsService();
    mockUserCubit = MockUserCubit();
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
    when(() => mockUserCubit.currentOnboardedUser).thenReturn(null);
    when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => const Stream.empty());
    for (final faction in Faction.values) {
      when(
        () => mockRepository.getImmortalForgesForFaction(faction),
      ).thenAnswer((_) async => const Result.success([]));
    }
  });

  group('ImmortalForgesCubit', () {
    test('init Success emits selectedFaction and forgeData', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.selectedFaction, Faction.gakki);
      expect(cubit.state.forgeData[Faction.gakki], leaders);
      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNull);
    });

    test('init Error emits error and isLoading false', () async {
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => Result.error(Exception('Network error')));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state.isLoading, false);
      expect(cubit.state.error, isNotNull);
    });

    test('changeFaction when cached does not call repository', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.changeFaction(Faction.gakki);

      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gakki)).called(1);
    });

    test('changeFaction when not cached calls repository', () async {
      final gakkiLeaders = [createTestImmortalForgeEntity()];
      final gyohyoLeaders = [createTestImmortalForgeEntity(userId: 2)];
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => Result.success(gakkiLeaders));
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gyohyo),
      ).thenAnswer((_) async => Result.error(Exception('Initial failure')));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gyohyo),
      ).thenAnswer((_) async => Result.success(gyohyoLeaders));
      await cubit.changeFaction(Faction.gyohyo);

      expect(cubit.state.forgeData[Faction.gyohyo], gyohyoLeaders);
      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gyohyo)).called(2);
    });

    test('refresh reloads all factions', () async {
      final leaders = [createTestImmortalForgeEntity()];
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => Result.success(leaders));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future.delayed(const Duration(milliseconds: 50));

      await cubit.refresh();

      for (final faction in Faction.values) {
        verify(() => mockRepository.getImmortalForgesForFaction(faction)).called(2);
      }
    });

    test('switches to a cached changed user faction and clears on logout', () async {
      final changes = StreamController<OnboardedUser?>.broadcast();
      when(() => mockUserCubit.currentOnboardedUser).thenReturn(createTestUser(Faction.gakki));
      when(() => mockUserCubit.onboardedUserChanges).thenAnswer((_) => changes.stream);
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gakki),
      ).thenAnswer((_) async => const Result.success([]));
      when(
        () => mockRepository.getImmortalForgesForFaction(Faction.gyohyo),
      ).thenAnswer((_) async => const Result.success([]));

      final cubit = ImmortalForgesCubit(mockRepository, mockAnalytics, mockUserCubit);
      await Future<void>.delayed(Duration.zero);

      changes.add(createTestUser(Faction.gyohyo));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.selectedFaction, Faction.gyohyo);
      verify(() => mockRepository.getImmortalForgesForFaction(Faction.gyohyo)).called(1);

      changes.add(createTestUser(Faction.gyohyo).copyWith(userName: 'Ignored'));
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockRepository.getImmortalForgesForFaction(Faction.gyohyo));

      changes.add(null);
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state, const ImmortalForgesState());

      await cubit.close();
      await changes.close();
    });
  });

  group('ImmortalForgesState currentList', () {
    test('returns forgeData for selectedFaction', () {
      final leaders = [createTestImmortalForgeEntity()];
      final state = ImmortalForgesState(
        forgeData: {Faction.gakki: leaders},
      );
      expect(state.currentList, leaders);
    });

    test('returns empty list when faction not in forgeData', () {
      const state = ImmortalForgesState();
      expect(state.currentList, isEmpty);
    });
  });
}
