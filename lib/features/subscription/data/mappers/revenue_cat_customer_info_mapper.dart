import 'dart:io';

import 'package:collection/collection.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';

SubscriptionPackage? _findMatchedPackage(
  String? productIdentifier,
  String? productPlanIdentifier,
  List<SubscriptionPackage> packages, {
  String? fallbackRcPackageGroupId,
}) {
  final purchasedId =
      Platform.isAndroid ? (productPlanIdentifier ?? productIdentifier) : productIdentifier;
  if (purchasedId != null) {
    final byProduct = packages.firstWhereOrNull(
      (p) => p.productIdentifier == purchasedId || p.id == purchasedId,
    );
    if (byProduct != null) return byProduct;
  }
  if (fallbackRcPackageGroupId != null && fallbackRcPackageGroupId.isNotEmpty) {
    return packages.firstWhereOrNull(
      (p) => p.rcPackageGroupId == fallbackRcPackageGroupId,
    );
  }
  return null;
}

SubscriptionEntity? mapCustomerInfo(
  CustomerInfo info, {
  List<SubscriptionPackage>? packages,
  String? fallbackRcPackageGroupId,
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
          fallbackRcPackageGroupId: fallbackRcPackageGroupId,
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
