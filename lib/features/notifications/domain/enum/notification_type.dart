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
        return 'New Plate Unlocked';
      case NotificationType.xpSummary:
        return 'XP Summary';
      case NotificationType.rankUpdate:
        return 'Rank Progress Update';
      case NotificationType.weeklyWinner:
        return 'Weekly Faction Winner';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.unknown:
        return t.notifications.defaultTitle;
    }
  }

  String description(Translations t) {
    switch (this) {
      case NotificationType.plateUnlocked:
        return 'New Plate Unlocked';
      case NotificationType.xpSummary:
        return 'XP Summary';
      case NotificationType.rankUpdate:
        return 'Rank Progress Update';
      case NotificationType.weeklyWinner:
        return 'Weekly Faction Winner';
      case NotificationType.paymentFailed:
        return 'Payment Failed';
      case NotificationType.unknown:
        return t.notifications.defaultTitle;
    }
  }
}
