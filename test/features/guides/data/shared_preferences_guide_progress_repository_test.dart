import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/guides/data/repositories/shared_preferences_guide_progress_repository.dart';
import 'package:reforge/features/guides/domain/entities/guide_id.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences preferences;
  late SharedPreferencesGuideProgressRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    repository = SharedPreferencesGuideProgressRepository(preferences);
  });

  test('an absent key means the guide is not completed', () async {
    final isCompleted = await repository.isCompleted(
      userId: 71,
      guideId: GuideId.leaderboard,
    );

    expect(isCompleted, isFalse);
  });

  test('completion is isolated by user and guide id', () async {
    await repository.markCompleted(
      userId: 71,
      guideId: GuideId.leaderboard,
    );

    expect(
      await repository.isCompleted(userId: 71, guideId: GuideId.leaderboard),
      isTrue,
    );
    expect(
      await repository.isCompleted(userId: 72, guideId: GuideId.leaderboard),
      isFalse,
    );
    expect(
      preferences.getBool('guides.71.leaderboard.completed'),
      isTrue,
    );
  });
}
