import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum NotificationType {
  @JsonValue('plateUnlocked')
  plateUnlocked,
  @JsonValue('xpSummary')
  xpSummary,
  @JsonValue('rankUpdate')
  rankUpdate,
  @JsonValue('weeklyWinner')
  weeklyWinner,
  @JsonValue('paymentFailed')
  paymentFailed,
  @JsonValue('unknown')
  unknown
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

extension NotificationTypeExtension on NotificationType {
  String title(Translations t) {
    switch (this) {
      case NotificationType.plateUnlocked:
        return 'New Plate Unlocked!';
      case NotificationType.xpSummary:
        return 'Weekly Gains Summary';
      case NotificationType.rankUpdate:
        return 'Rank Level Up!';
      case NotificationType.weeklyWinner:
        return 'Weekly Champion!';
      case NotificationType.paymentFailed:
        return 'Subscription Issue';
      case NotificationType.unknown:
        return 'New Update';
    }
  }

  String description(Translations t) {
    switch (this) {
      case NotificationType.plateUnlocked:
        return 'Incredible! You’ve earned a new plate. Check out your updated collection in the profile.';
      case NotificationType.xpSummary:
        return 'Your weekly effort in numbers. See how much XP you’ve racked up this week!';
      case NotificationType.rankUpdate:
        return 'Witness the fitness! You’ve just reached a new rank. Keep pushing to the next level.';
      case NotificationType.weeklyWinner:
        return 'You crushed the competition and took the top spot this week. Legend!';
      case NotificationType.paymentFailed:
        return 'We couldn’t process your payment. Update your billing info to keep your streak alive.';
      case NotificationType.unknown:
        return 'Something new is happening in Reforge. Open the app to check it out.';
    }
  }
}
