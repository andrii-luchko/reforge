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
        return t.subscription.periodType.unknown;
      case SubscriptionPeriodType.custom:
        return t.subscription.periodType.custom;
      case SubscriptionPeriodType.lifetime:
        return t.subscription.periodType.lifetime;
      case SubscriptionPeriodType.annual:
        return t.subscription.periodType.yearly;
      case SubscriptionPeriodType.sixMonth:
        return t.subscription.periodType.sixMonths;
      case SubscriptionPeriodType.threeMonth:
        return t.subscription.periodType.threeMonths;
      case SubscriptionPeriodType.twoMonth:
        return t.subscription.periodType.twoMonths;
      case SubscriptionPeriodType.monthly:
        return t.subscription.periodType.monthly;
      case SubscriptionPeriodType.weekly:
        return t.subscription.periodType.weekly;
    }
  }

  String displayPeriod(Translations t) {
    switch (this) {
      case SubscriptionPeriodType.unknown:
        return t.subscription.periodType.perUnknown;
      case SubscriptionPeriodType.custom:
        return t.subscription.periodType.perCustom;
      case SubscriptionPeriodType.lifetime:
        return t.subscription.periodType.perOneTime;
      case SubscriptionPeriodType.annual:
        return t.subscription.periodType.perYear;
      case SubscriptionPeriodType.sixMonth:
        return t.subscription.periodType.perSixMonths;
      case SubscriptionPeriodType.threeMonth:
        return t.subscription.periodType.perThreeMonths;
      case SubscriptionPeriodType.twoMonth:
        return t.subscription.periodType.perTwoMonths;
      case SubscriptionPeriodType.monthly:
        return t.subscription.periodType.perMonth;
      case SubscriptionPeriodType.weekly:
        return t.subscription.periodType.perWeek;
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
        return t.subscription.periodType.limitedTimeOffer;
      case SubscriptionPeriodType.annual:
        return t.subscription.periodType.bestOffer;
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
        return t.subscription.periodType.descriptionLifetime;
      case SubscriptionPeriodType.annual:
        return t.subscription.periodType.descriptionAnnual;
      case SubscriptionPeriodType.sixMonth:
        return '';
      case SubscriptionPeriodType.threeMonth:
        return '';
      case SubscriptionPeriodType.twoMonth:
        return '';
      case SubscriptionPeriodType.monthly:
        return t.subscription.periodType.descriptionMonthly;
      case SubscriptionPeriodType.weekly:
        return '';
    }
  }
}
