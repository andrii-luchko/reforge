import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

void main() {
  group('RankEntity', () {
    group('progress', () {
      test('returns xp divided by maxXp', () {
        final entity = RankEntity(
          imageAsset: '',
          rankName: 'Test',
          faction: Faction.gakki,
          lvl: 5,
          xp: 500,
          maxXp: 1000,
          japanRankName: '',
        );
        expect(entity.progress, 0.5);
      });

      test('clamps to 0 when xp is 0', () {
        final entity = RankEntity(
          imageAsset: '',
          rankName: 'Test',
          faction: Faction.gakki,
          lvl: 1,
          xp: 0,
          maxXp: 1000,
          japanRankName: '',
        );
        expect(entity.progress, 0);
      });

      test('clamps to 1 when xp >= maxXp', () {
        final entity = RankEntity(
          imageAsset: '',
          rankName: 'Test',
          faction: Faction.gakki,
          lvl: 10,
          xp: 1000,
          maxXp: 1000,
          japanRankName: '',
        );
        expect(entity.progress, 1);

        final entityOver = RankEntity(
          imageAsset: '',
          rankName: 'Test',
          faction: Faction.gakki,
          lvl: 10,
          xp: 1500,
          maxXp: 1000,
          japanRankName: '',
        );
        expect(entityOver.progress, 1);
      });
    });
  });
}
