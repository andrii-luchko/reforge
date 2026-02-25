import 'package:intl/intl.dart';

import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';

/// Trial/intro offer info for display.
class SubscriptionTrialInfo {
  const SubscriptionTrialInfo({
    this.price,
    this.priceString,
    this.period,
    this.currencyCode,
  });

  final double? price;
  final String? priceString;
  final String? period;
  final String? currencyCode;
}

/// A subscription package available for purchase.
class SubscriptionPackage {
  const SubscriptionPackage({
    required this.id,
    required this.title,
    required this.price,
    required this.priceString,
    required this.currencyCode,
    required this.periodType,
    this.productIdentifier,
    this.period,
    this.trialInfo,
  });

  final String id;
  final String title;
  final double price;
  final String priceString;
  final String currencyCode;
  final SubscriptionPeriodType periodType;
  final String? period;
  final SubscriptionTrialInfo? trialInfo;
  final String? productIdentifier;

  String get displayPrice {
    final code = trialInfo?.currencyCode ?? currencyCode;
    final amount = trialInfo?.price ?? price;

    try {
      final formatter = NumberFormat.simpleCurrency(name: code);

      final symbol = formatter.currencySymbol;

      final numberFormatter = NumberFormat.decimalPattern()
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2;

      final formattedNumber = numberFormatter.format(amount);

      return '$symbol\u00A0$formattedNumber';
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return '$code $amount';
    }
  }

  String formattedPrice(double amount) {
    final code = trialInfo?.currencyCode ?? currencyCode;

    try {
      final formatter = NumberFormat.simpleCurrency(name: code);

      final symbol = formatter.currencySymbol;

      final numberFormatter = NumberFormat.decimalPattern()
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2;

      final formattedNumber = numberFormatter.format(amount);

      return '$symbol\u00A0$formattedNumber';
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      return '$code $amount';
    }
  }

  @override
  String toString() {
    return 'SubscriptionPackage(id: $id, title: $title, price: $price, priceString: $priceString, currencyCode: $currencyCode, periodType: $periodType, period: $period, trialInfo: $trialInfo, productIdentifier: $productIdentifier)';
  }
}

extension SubscriptionPackagePlaceholder on SubscriptionPackage {
  static const placeholder = SubscriptionPackage(
    id: 'skeleton',
    title: 'Monthly',
    price: 9.99,
    priceString: r'$9.99',
    currencyCode: 'USD',
    periodType: SubscriptionPeriodType.monthly,
  );
}
