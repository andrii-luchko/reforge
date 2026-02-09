import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

class BadgesGenerator {
  BadgesGenerator._();
  static List<BadgeEntity> generateBadges() {
    return List.generate(10, (i) {
      return BadgeEntity(
        imageUrl: Assets.images.png.badge.path,
        title: 'Peak\nof Might',
        isLocked: i <= 5,
      );
    });
  }
}
