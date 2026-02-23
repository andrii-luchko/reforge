import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_user_entity.dart';

import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_users.dart';

void main() {
  group('generateMockUsers', () {
    test('returns 10 items', () {
      final users = generateMockUsers();
      expect(users.length, 10);
    });

    test('each item has valid structure', () {
      final users = generateMockUsers();
      for (final user in users) {
        expect(user.rank, inInclusiveRange(1, 10));
        expect(user.username, isNotEmpty);
        expect(user.xp, greaterThanOrEqualTo(0));
        expect(user, isA<LeaderboardUserEntity>());
      }
    });

    test('ranks are sequential', () {
      final users = generateMockUsers();
      for (var i = 0; i < users.length; i++) {
        expect(users[i].rank, i + 1);
      }
    });
  });
}
