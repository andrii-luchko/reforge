import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/controller/factions_leaderboard_cubit.dart/factions_leaderboard_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/faction_wars_guide_eligibility.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

const _gakki = LeaderboardFactionModel(
  faction: Faction.gakki,
  xp: 1000,
  activeUsers: 10,
  globalScore: 2,
  localScore: 1,
);

const _gyohyo = LeaderboardFactionModel(
  faction: Faction.gyohyo,
  xp: 900,
  activeUsers: 9,
  globalScore: 1,
  localScore: 0,
);

void main() {
  test('allows loaded faction list with a user matchup', () {
    const state = FactionsLeaderboardState(
      factions: [_gakki, _gyohyo],
      userFaction: Faction.gakki,
    );

    expect(
      canStartFactionWarsGuide(
        mode: LeaderboardMode.factions,
        state: state,
        userId: 71,
      ),
      isTrue,
    );
  });

  test('rejects unavailable data, wrong mode, and victory-points view', () {
    const loaded = FactionsLeaderboardState(
      factions: [_gakki, _gyohyo],
      userFaction: Faction.gakki,
    );

    final scenarios = [
      (mode: LeaderboardMode.users, state: loaded, userId: 71),
      (
        mode: LeaderboardMode.factions,
        state: loaded.copyWith(isLoading: true),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.factions,
        state: loaded.copyWith(error: 'offline'),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.factions,
        state: const FactionsLeaderboardState(),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.factions,
        state: loaded.copyWith(userFaction: null),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.factions,
        state: loaded.copyWith(selectedType: FactionShowType.victoryPoints),
        userId: 71,
      ),
      (mode: LeaderboardMode.factions, state: loaded, userId: null),
    ];

    for (final scenario in scenarios) {
      expect(
        canStartFactionWarsGuide(
          mode: scenario.mode,
          state: scenario.state,
          userId: scenario.userId,
        ),
        isFalse,
      );
    }
  });
}
