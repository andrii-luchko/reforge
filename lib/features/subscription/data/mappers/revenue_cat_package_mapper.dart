import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

SubscriptionPeriodType periodTypeFromPackageType(PackageType rcType) {
  switch (rcType) {
    case PackageType.unknown:
      return SubscriptionPeriodType.unknown;
    case PackageType.custom:
      return SubscriptionPeriodType.custom;
    case PackageType.lifetime:
      return SubscriptionPeriodType.lifetime;
    case PackageType.annual:
      return SubscriptionPeriodType.annual;
    case PackageType.sixMonth:
      return SubscriptionPeriodType.sixMonth;
    case PackageType.threeMonth:
      return SubscriptionPeriodType.threeMonth;
    case PackageType.twoMonth:
      return SubscriptionPeriodType.twoMonth;
    case PackageType.monthly:
      return SubscriptionPeriodType.monthly;
    case PackageType.weekly:
      return SubscriptionPeriodType.weekly;
  }
}

/// Returns a localized trial period string using pluralized durations from i18n.
String? displayTrialPeriod(int? unitsCount, PeriodUnit? unit) {
  if (unitsCount == null || unit == null) return null;
  if (unit == PeriodUnit.unknown) return null;

  switch (unit) {
    case PeriodUnit.day:
      return t.common.durations.day(n: unitsCount);
    case PeriodUnit.week:
      return t.common.durations.week(n: unitsCount);
    case PeriodUnit.month:
      return t.common.durations.month(n: unitsCount);
    case PeriodUnit.year:
      return t.common.durations.year(n: unitsCount);
    case PeriodUnit.unknown:
      return null;
  }
}

Package? findPackageById(Offerings offerings, String packageId) {
  final current = offerings.current;
  if (current == null) return null;
  for (final p in current.availablePackages) {
    if (p.identifier == packageId) return p;
  }
  return null;
}

SubscriptionPackage mapPackage(Package rcPackage) {
  final product = rcPackage.storeProduct;
  return SubscriptionPackage(
    id: rcPackage.identifier,
    title: product.title,
    price: product.price,
    priceString: product.priceString,
    currencyCode: product.currencyCode,
    productIdentifier: product.identifier,
    periodType: periodTypeFromPackageType(rcPackage.packageType),
    period: product.subscriptionPeriod,
    trialInfo: product.introductoryPrice != null
        ? SubscriptionTrialInfo(
            price: product.introductoryPrice!.price,
            priceString: product.introductoryPrice!.priceString,
            periodParsed: displayTrialPeriod(
              product.introductoryPrice?.periodNumberOfUnits,
              product.introductoryPrice?.periodUnit,
            ),
            currencyCode: product.currencyCode,
          )
        : null,
  );
}
