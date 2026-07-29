import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:reforge/features/guides/ui/guides/leaderboard_guide.dart';

void main() {
  test('defines one stable step for every leaderboard guide target', () {
    final guide = LeaderboardGuide();
    final session = guide.session;

    expect(session.id, GuideId.leaderboard);
    expect(session.steps, hasLength(8));
    expect(
      session.steps.map((step) => step.anchor),
      LeaderboardGuideStep.values.map(guide.anchor),
    );
  });
}
