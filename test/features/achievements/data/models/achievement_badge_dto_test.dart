import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/achievements/data/mock/achievement_badges_mock.dart';
import 'package:reforge/features/achievements/data/models/achievement_badge_dto.dart';

void main() {
  group('AchievementBadgeDto', () {
    test('provides the proposed workout milestones response', () {
      expect(mockAchievementBadges, hasLength(30));

      for (final badge in mockAchievementBadges) {
        final displayedTier = badge.userProgress?.tier ?? 1;
        expect(
          badge.iconUrl,
          endsWith('/${badge.iconUrlKey}-$displayedTier.svg'),
          reason: '${badge.name} must return the current tier image',
        );
        expect(badge.requirementTitle, isNotEmpty);
        expect(badge.description, isNotEmpty);
      }

      final locked = mockAchievementBadges.firstWhere(
        (badge) => badge.name == 'Warden',
      );
      final lockedDomain = locked.toDomain();
      expect(lockedDomain.isLocked, isTrue);
      expect(lockedDomain.tier, isNull);
      expect(lockedDomain.factionId, 1);
      expect(lockedDomain.requirementTitle, 'Squat 1RM');
      expect(lockedDomain.imageUrl, endsWith('/squat-1rm-1.svg'));

      final unlocked = mockAchievementBadges.firstWhere(
        (badge) => badge.name == 'Daystar Scout',
      );
      final unlockedDomain = unlocked.toDomain();
      expect(unlockedDomain.isLocked, isFalse);
      expect(unlockedDomain.tier, 4);
      expect(unlockedDomain.key, '5mile');
      expect(unlockedDomain.exerciseMetric, 'durationSec');
      expect(unlockedDomain.imageUrl, endsWith('/5mile-4.svg'));
    });

    test('keeps the new backend fields optional during rollout', () {
      final dto = AchievementBadgeDto.fromJson({
        'id': 1,
        'name': 'Warden',
        'key': 'squat',
        'isCompleted': false,
      });

      expect(dto.factionId, isNull);
      expect(dto.requirementTitle, isNull);
      expect(dto.description, isNull);
      expect(dto.toDomain().imageUrl, isEmpty);
    });
  });
}
