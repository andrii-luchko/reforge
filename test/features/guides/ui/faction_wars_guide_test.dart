import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/faction_wars_guide.dart';

void main() {
  test('defines the fixed Faction Wars step order', () {
    final guide = FactionWarsGuide();
    final session = guide.session;

    expect(session.id, GuideId.factionWars);
    expect(session.steps, hasLength(5));
    expect(
      session.steps.map((step) => step.anchor),
      FactionWarsGuideStep.values.map(guide.anchor),
    );
  });
}
