import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/core/network/api_client.dart';
import 'package:reforge/features/achievements/data/mock/achievement_badges_mock.dart';
import 'package:reforge/features/achievements/data/repositories/achievements_repository.dart';

class _MockApiClient extends Mock implements ApiClient {}

void main() {
  test('uses the connected workout milestones mock in debug', () async {
    final apiClient = _MockApiClient();
    final repository = AchievementsRepositoryImpl(apiClient);

    final result = await repository.getUserBadges();

    expect(useMockWorkoutMilestones, isTrue);
    expect(result.isSuccess, isTrue);
    expect(result.orNull, hasLength(mockAchievementBadges.length));
    verifyNever(apiClient.getUserBadges);
  });
}
