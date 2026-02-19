import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

import '../../../core/analytics/mocks/mock_analytics_service.dart';
import '../../../helpers/test_setup.dart';
import '../mocks/mock_leaderboard_repository.dart';

LeaderboardFactionModel createTestFactionModel(
  Faction faction, {
  int xp = 1000,
  int activeUsers = 50,
  int globalScore = 100,
  int localScore = 42,
}) {
  return LeaderboardFactionModel(
    faction: faction,
    xp: xp,
    activeUsers: activeUsers,
    globalScore: globalScore,
    localScore: localScore,
  );
}

void main() {
  late MockLeaderboardRepository mockRepository;
  late MockAnalyticsService mockAnalytics;

  setUpAll(initTestTranslations);

  setUp(() {
    mockRepository = MockLeaderboardRepository();
    mockAnalytics = MockAnalyticsService();
    when(() => mockAnalytics.logEvent(any(), any())).thenAnswer((_) async {});
    when(() => mockAnalytics.logEvent(any())).thenAnswer((_) async {});
  });

  group('FactionsLeaderboardCubit', () {
    group('loadFactions', () {
      test('Success emits factions and userFaction', () async {
        final factions = [
          createTestFactionModel(Faction.gakki),
          createTestFactionModel(Faction.gyohyo),
        ];
        when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
        when(() => mockRepository.getFactionsLeaderboard())
            .thenAnswer((_) async => Result.success(factions));

        final cubit = FactionsLeaderboardCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.factions, hasLength(2));
        expect(cubit.state.userFaction, Faction.gakki);
        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNull);
      });

      test('Error emits error and isLoading false', () async {
        when(() => mockRepository.getUserFaction()).thenReturn(null);
        when(() => mockRepository.getFactionsLeaderboard())
            .thenAnswer((_) async => Result.error(Exception('Network error')));

        final cubit = FactionsLeaderboardCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(cubit.state.isLoading, false);
        expect(cubit.state.error, isNotNull);
      });

      test('when isLoading does not call repository', () async {
        final completer = Completer<Result<List<LeaderboardFactionModel>>>();
        when(() => mockRepository.getUserFaction()).thenReturn(Faction.gakki);
        when(() => mockRepository.getFactionsLeaderboard()).thenAnswer((_) => completer.future);

        final cubit = FactionsLeaderboardCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 10));

        await cubit.loadFactions();

        verify(() => mockRepository.getFactionsLeaderboard()).called(1);
      });
    });

    group('changeMode', () {
      test('emits state with selectedMode', () async {
        when(() => mockRepository.getUserFaction()).thenReturn(null);
        when(() => mockRepository.getFactionsLeaderboard())
            .thenAnswer((_) async => const Result.success([]));

        final cubit = FactionsLeaderboardCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        cubit.changeMode(FactionMode.global);

        expect(cubit.state.selectedMode, FactionMode.global);
      });
    });

    group('changeShowType', () {
      test('emits state with selectedType', () async {
        when(() => mockRepository.getUserFaction()).thenReturn(null);
        when(() => mockRepository.getFactionsLeaderboard())
            .thenAnswer((_) async => const Result.success([]));

        final cubit = FactionsLeaderboardCubit(mockRepository, mockAnalytics);
        await Future.delayed(const Duration(milliseconds: 50));

        cubit.changeShowType(FactionShowType.victoryPoints);

        expect(cubit.state.selectedType, FactionShowType.victoryPoints);
      });
    });
  });

  group('FactionsLeaderboardState getters', () {
    test('versusMatchup returns null when factions empty', () {
      const state = FactionsLeaderboardState(
        userFaction: Faction.gakki,
      );
      expect(state.versusMatchup, isNull);
    });

    test('versusMatchup returns null when userFaction null', () {
      final state = FactionsLeaderboardState(
        factions: [createTestFactionModel(Faction.gakki)],
      );
      expect(state.versusMatchup, isNull);
    });

    test('versusMatchup returns myFaction and opponent when data present', () {
      final gakki = createTestFactionModel(Faction.gakki, localScore: 10, globalScore: 50);
      final gyohyo = createTestFactionModel(Faction.gyohyo, localScore: 20, globalScore: 40);
      final state = FactionsLeaderboardState(
        factions: [gakki, gyohyo],
        userFaction: Faction.gyohyo,
      );
      final matchup = state.versusMatchup;
      expect(matchup, isNotNull);
      expect(matchup!.myFaction.faction, Faction.gyohyo);
      expect(matchup.opponent.faction, Faction.gakki);
    });

    test('factionsSortByMode returns empty when factions empty', () {
      const state = FactionsLeaderboardState();
      expect(state.factionsSortByMode, isEmpty);
    });

    test('factionsSortByMode sorts by score desc then by name', () {
      final low = createTestFactionModel(Faction.gakki, localScore: 10, globalScore: 10);
      final high = createTestFactionModel(Faction.gyohyo, localScore: 50, globalScore: 50);
      final state = FactionsLeaderboardState(
        factions: [low, high],
      );
      final sorted = state.factionsSortByMode;
      expect(sorted.first.faction, Faction.gyohyo);
      expect(sorted.last.faction, Faction.gakki);
    });
  });
}
