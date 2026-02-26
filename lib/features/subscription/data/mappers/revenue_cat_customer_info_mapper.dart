import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';

SubscriptionPackage? _findMatchedPackage(
  String? productIdentifier,
  String? productPlanIdentifier,
  List<SubscriptionPackage> packages,
) {
  final purchasedId =
      Platform.isAndroid ? (productPlanIdentifier ?? productIdentifier) : productIdentifier;
  if (purchasedId == null) return null;
  try {
    return packages.firstWhere(
      (p) => p.productIdentifier == purchasedId || p.id == purchasedId,
    );
    // ignore: avoid_catches_without_on_clauses
  } catch (_) {
    return null;
  }
}

SubscriptionEntity? mapCustomerInfo(
  CustomerInfo info, {
  List<SubscriptionPackage>? packages,
}) {
  final active = info.entitlements.active;
  if (active.isEmpty) {
    return null;
  }
  final first = active.values.first;
  DateTime? expirationDate;
  if (first.expirationDate != null) {
    expirationDate = DateTime.tryParse(first.expirationDate!);
  }
  final matchedPackage = packages != null
      ? _findMatchedPackage(
          first.productIdentifier,
          first.productPlanIdentifier,
          packages,
        )
      : null;
  return SubscriptionEntity(
    isActive: first.isActive,
    expirationDate: expirationDate,
    entitlementId: first.identifier,
    productIdentifier: first.productIdentifier,
    productPlanIdentifier: first.productPlanIdentifier,
    matchedPackage: matchedPackage,
    managementUrl: info.managementURL,
  );
}
