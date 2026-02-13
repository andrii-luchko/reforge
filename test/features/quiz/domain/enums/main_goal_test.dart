import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/features/quiz/domain/enums/main_goal.dart';

void main() {
  group('FitnessGoalExtension.faction', () {
    test('buildStrength returns Faction.gakki', () {
      expect(MainGoal.buildStrength.faction, Faction.gakki);
    });

    test('improveEndurance returns Faction.gyohyo', () {
      expect(MainGoal.improveEndurance.faction, Faction.gyohyo);
    });

    test('enhanceFlexibility returns Faction.seiren', () {
      expect(MainGoal.enhanceFlexibility.faction, Faction.seiren);
    });
  });
}
