import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_factions.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

void main() {
  group('generateMockFactions', () {
    test('returns all Faction values', () {
      final factions = generateMockFactions();
      expect(factions.length, Faction.values.length);
    });

    test('each faction appears once', () {
      final factions = generateMockFactions();
      final factionSet = factions.map((f) => f.faction).toSet();
      expect(factionSet.length, Faction.values.length);
    });

    test('deterministic with seed', () {
      final first = generateMockFactions();
      final second = generateMockFactions();
      expect(first.length, second.length);
      for (var i = 0; i < first.length; i++) {
        expect(first[i].faction, second[i].faction);
        expect(first[i].xp, second[i].xp);
        expect(first[i].activeUsers, second[i].activeUsers);
        expect(first[i].globalScore, second[i].globalScore);
        expect(first[i].localScore, second[i].localScore);
      }
    });
  });
}
