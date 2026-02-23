import 'package:reforge/generated/i18n/translations.g.dart';

/// Subscription period type, mirrors RevenueCat PackageType.
enum SubscriptionPeriodType {
  unknown,
  custom,
  lifetime,
  annual,
  sixMonth,
  threeMonth,
  twoMonth,
  monthly,
  weekly,
}

extension SubscriptionPeriodTypeX on SubscriptionPeriodType {
  String displayName(Translations t) {
    switch (this) {
      case SubscriptionPeriodType.unknown:
        return 'Unknown';
      case SubscriptionPeriodType.custom:
        return 'Custom';
      case SubscriptionPeriodType.lifetime:
        return 'Foundry Member Pass';
      case SubscriptionPeriodType.annual:
        return 'Yearly';
      case SubscriptionPeriodType.sixMonth:
        return '6 Months';
      case SubscriptionPeriodType.threeMonth:
        return '3 Months';
      case SubscriptionPeriodType.twoMonth:
        return '2 Months';
      case SubscriptionPeriodType.monthly:
        return 'Monthly';
      case SubscriptionPeriodType.weekly:
        return 'Weekly';
    }
  }

  String displayPeriod(Translations t) {
    switch (this) {
      case SubscriptionPeriodType.unknown:
        return '/ unknown';
      case SubscriptionPeriodType.custom:
        return '/ custom';
      case SubscriptionPeriodType.lifetime:
        return '/ one time';
      case SubscriptionPeriodType.annual:
        return '/ year';
      case SubscriptionPeriodType.sixMonth:
        return '/ 6 months';
      case SubscriptionPeriodType.threeMonth:
        return '/ 3 months';
      case SubscriptionPeriodType.twoMonth:
        return '/ 2 months';
      case SubscriptionPeriodType.monthly:
        return '/ month';
      case SubscriptionPeriodType.weekly:
        return '/ week';
    }
  }

  int get tier => switch (this) {
    SubscriptionPeriodType.lifetime => 100,
    SubscriptionPeriodType.annual => 4,
    SubscriptionPeriodType.sixMonth => 3,
    SubscriptionPeriodType.threeMonth => 2,
    SubscriptionPeriodType.monthly => 1,
    SubscriptionPeriodType.weekly => 0,
    _ => -1,
  };

  bool isUpgradeFrom(SubscriptionPeriodType other) => tier > other.tier;

  bool isDowngradeFrom(SubscriptionPeriodType other) => tier < other.tier && tier >= 0;

  String? displayTag(Translations t) {
    switch (this) {
      case SubscriptionPeriodType.unknown:
      case SubscriptionPeriodType.custom:
        return null;
      case SubscriptionPeriodType.lifetime:
        return 'Limited time offer!';
      case SubscriptionPeriodType.annual:
        return 'Best offer';
      case SubscriptionPeriodType.sixMonth:
        return null;
      case SubscriptionPeriodType.threeMonth:
        return null;
      case SubscriptionPeriodType.twoMonth:
        return null;
      case SubscriptionPeriodType.monthly:
        return null;
      case SubscriptionPeriodType.weekly:
        return null;
    }
  }

  String description(Translations t, String savings) {
    switch (this) {
      case SubscriptionPeriodType.unknown:
      case SubscriptionPeriodType.custom:
        return '';
      case SubscriptionPeriodType.lifetime:
        return 'Lifetime access to all features, all factions, and exclusive status.';
      case SubscriptionPeriodType.annual:
        // return 'Save $savings annually compared to monthly billing. Full access to all features and all factions.';
        return 'Save more than 40% compared to the monthly plan. Full access to all features and all factions.';
      case SubscriptionPeriodType.sixMonth:
        return '';
      case SubscriptionPeriodType.threeMonth:
        return '';
      case SubscriptionPeriodType.twoMonth:
        return '';
      case SubscriptionPeriodType.monthly:
        return 'Unlimited access to all premium features and exclusive content. No limits, just results.';
      case SubscriptionPeriodType.weekly:
        return '';
    }
  }
}
