import 'package:reforge/generated/flutter_gen/assets.gen.dart';

enum NotificationType {
  plateUnlocked,
  xpSummary,
  rankUpdate,
  weeklyWinner,
  paymentFailed,
  unknown,
  ;

  String get iconAsset {
    return switch (this) {
      plateUnlocked => Assets.images.icons.platesInactive,
      xpSummary => Assets.images.icons.medal,
      rankUpdate => Assets.images.icons.cup,
      weeklyWinner => Assets.images.icons.medalInactive,
      paymentFailed => Assets.images.icons.cardRemove,
      unknown => Assets.images.icons.bell,
    };
  }
}
