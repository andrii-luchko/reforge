import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/controller/immortal_forges_cubit.dart/immortal_forges_cubit.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/leaderboard/domain/enum/leaderboard_mode.dart';
import 'package:reforge/features/leaderboard/ui/guide/leaderboard_guide_eligibility.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

const _leader = ImmortalForgeEntity(
  userId: 1,
  email: 'leader@example.com',
  score: 100,
  rank: 1,
  title: 'Daizōshō',
);

void main() {
  test('allows an onboarded user with fully loaded non-empty data', () {
    const state = ImmortalForgesState(
      forgeData: {
        Faction.gakki: [_leader],
        Faction.gyohyo: [_leader],
        Faction.seiren: [_leader],
      },
    );

    expect(
      canStartLeaderboardGuide(
        mode: LeaderboardMode.users,
        state: state,
        userId: 71,
      ),
      isTrue,
    );
  });

  test('rejects loading, error, empty card, missing user, and factions mode', () {
    const loadedData = {
      Faction.gakki: [_leader],
      Faction.gyohyo: [_leader],
      Faction.seiren: [_leader],
    };

    final scenarios = [
      (
        mode: LeaderboardMode.users,
        state: const ImmortalForgesState(isLoading: true, forgeData: loadedData),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.users,
        state: const ImmortalForgesState(error: 'offline', forgeData: loadedData),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.users,
        state: const ImmortalForgesState(
          forgeData: {
            Faction.gakki: [],
            Faction.gyohyo: [_leader],
            Faction.seiren: [_leader],
          },
        ),
        userId: 71,
      ),
      (
        mode: LeaderboardMode.users,
        state: const ImmortalForgesState(forgeData: loadedData),
        userId: null,
      ),
      (
        mode: LeaderboardMode.factions,
        state: const ImmortalForgesState(forgeData: loadedData),
        userId: 71,
      ),
    ];

    for (final scenario in scenarios) {
      expect(
        canStartLeaderboardGuide(
          mode: scenario.mode,
          state: scenario.state,
          userId: scenario.userId,
        ),
        isFalse,
      );
    }
  });
}
