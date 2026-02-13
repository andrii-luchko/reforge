import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/leaderboard/domain/helpers/top_five_titles_by_rank.dart';

void main() {
  group('topFiveTitlesByRank', () {
    test('ranks 1-5 return correct titles', () {
      expect(topFiveTitlesByRank(1), 'Daizōshō');
      expect(topFiveTitlesByRank(2), 'Might');
      expect(topFiveTitlesByRank(3), 'Judgement');
      expect(topFiveTitlesByRank(4), 'Strife');
      expect(topFiveTitlesByRank(5), 'Burden');
    });

    test('rank 6 and above returns Soldier', () {
      expect(topFiveTitlesByRank(6), 'Soldier');
      expect(topFiveTitlesByRank(10), 'Soldier');
      expect(topFiveTitlesByRank(100), 'Soldier');
    });

    test('rank 0 or negative returns Soldier', () {
      expect(topFiveTitlesByRank(0), 'Soldier');
      expect(topFiveTitlesByRank(-1), 'Soldier');
    });
  });
}
