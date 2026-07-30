import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

void main() {
  group('UserStats', () {
    test('new user stats use the approved defaults', () {
      final stats = UserStats.newUser();

      expect(stats.level, 51);
      expect(stats.xpToNextLevel, 1000);
      expect(stats.totalXp, 0);
      expect(stats.totalWorkoutsDuration, 0);
      expect(stats.workoutsCount, 0);
      expect(stats.activeDays, 0);
      expect(stats.totalDays, 3);
      expect(stats.badgeName, isNull);
      expect(stats.badgeImageUrl, isNull);
      expect(stats.currentXp, 0);
      expect(stats.xpGoal, 1000);
    });

    group('currentXp', () {
      test('returns totalXp minus xpToNextLevel when positive', () {
        final stats = UserStatsX.mock();
        expect(stats.currentXp, 1550);
      });

      test('clamps to 0 when result is negative', () {
        final stats = UserStatsX.mock(
          totalXp: 1000,
          xpToNextLevel: 1500,
        );
        expect(stats.currentXp, 0);
      });

      test('clamps to totalXp when result exceeds totalXp', () {
        final stats = UserStatsX.mock(
          totalXp: 1000,
          xpToNextLevel: 0,
        );
        expect(stats.currentXp, 1000);
      });
    });

    group('xpGoal', () {
      test('uses total XP when it is positive', () {
        final stats = UserStatsX.mock();
        expect(stats.xpGoal, 2000);
      });

      test('uses XP to next level when total XP is zero', () {
        final stats = UserStatsX.mock(
          totalXp: 0,
          xpToNextLevel: 1000,
        );
        expect(stats.xpGoal, 1000);
      });
    });

    group('UserStatsX.durationFormatted', () {
      test('delegates to int extension for 3665 seconds', () {
        final stats = UserStatsX.mock();
        final formatted = stats.durationFormatted;
        expect(formatted.hours, 1);
        expect(formatted.minutes, 1);
      });

      test('returns 0 hours and 0 minutes for 0 seconds', () {
        final stats = UserStatsX.mock(totalWorkoutsDuration: 0);
        final formatted = stats.durationFormatted;
        expect(formatted.hours, 0);
        expect(formatted.minutes, 0);
      });

      test('returns correct values for 90 seconds', () {
        final stats = UserStatsX.mock(totalWorkoutsDuration: 90);
        final formatted = stats.durationFormatted;
        expect(formatted.hours, 0);
        expect(formatted.minutes, 1);
      });
    });
  });
}
