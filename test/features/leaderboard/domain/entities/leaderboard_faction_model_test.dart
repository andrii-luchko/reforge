import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

void main() {
  group('LeaderboardFactionModel', () {
    group('scoreByMode', () {
      test('currentFight returns localScore', () {
        const model = LeaderboardFactionModel(
          faction: Faction.gakki,
          xp: 1000,
          activeUsers: 50,
          globalScore: 100,
          localScore: 42,
        );
        expect(model.scoreByMode(FactionMode.currentFight), 42);
      });

      test('global returns globalScore', () {
        const model = LeaderboardFactionModel(
          faction: Faction.gakki,
          xp: 1000,
          activeUsers: 50,
          globalScore: 100,
          localScore: 42,
        );
        expect(model.scoreByMode(FactionMode.global), 100);
      });
    });
  });
}
