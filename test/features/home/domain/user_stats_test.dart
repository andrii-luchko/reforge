import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/home/domain/user_stats.dart';

void main() {
  group('UserStats', () {
    group('currentXp', () {
      test('returns totalXp minus xpToNextLevel when positive', () {
        final stats = UserStatsX.mock(
          totalXp: 2000,
          xpToNextLevel: 450,
        );
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

    group('UserStatsX.durationFormatted', () {
      test('delegates to int extension for 3665 seconds', () {
        final stats = UserStatsX.mock(totalWorkoutsDuration: 3665);
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
