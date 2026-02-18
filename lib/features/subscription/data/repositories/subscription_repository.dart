import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/features/subscription/domain/repositories/subscription_repository.dart' as domain;
import 'package:reforge/generated/i18n/translations.g.dart';

SubscriptionPeriodType _periodTypeFromPackageType(PackageType rcType) {
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

Exception? _transformRevenueCatError(Object error, StackTrace _) {
  if (error is! PlatformException) return null;
  final code = PurchasesErrorHelper.getErrorCode(error);
  if (code == PurchasesErrorCode.purchaseCancelledError) {
    return const PurchaseCancelledException();
  }
  return Exception(_revenueCatToUserMessage(code));
}

String _revenueCatToUserMessage(PurchasesErrorCode code) {
  switch (code) {
    case PurchasesErrorCode.networkError:
    case PurchasesErrorCode.offlineConnectionError:
      return t.errors.no_internet;
    case PurchasesErrorCode.purchaseNotAllowedError:
    case PurchasesErrorCode.insufficientPermissionsError:
      return t.errors.purchase_not_allowed;
    case PurchasesErrorCode.productNotAvailableForPurchaseError:
      return t.errors.product_unavailable;
    case PurchasesErrorCode.storeProblemError:
      return t.errors.store_error;
    // ignore: no_default_cases
    default:
      return t.errors.unexpected;
  }
}

@Injectable(as: domain.SubscriptionRepository)
class SubscriptionRepositoryImpl with RepositoryErrorHandler implements domain.SubscriptionRepository {
  Package? _findPackageById(Offerings offerings, String packageId) {
    final current = offerings.current;
    if (current == null) return null;
    for (final p in current.availablePackages) {
      if (p.identifier == packageId) return p;
    }
    return null;
  }

  SubscriptionPackage _mapPackage(Package rcPackage) {
    final product = rcPackage.storeProduct;
    return SubscriptionPackage(
      id: rcPackage.identifier,
      title: product.title,
      price: product.price,
      priceString: product.priceString,
      currencyCode: product.currencyCode,
      productIdentifier: product.identifier,
      periodType: _periodTypeFromPackageType(rcPackage.packageType),
      period: product.subscriptionPeriod,
      trialInfo: product.introductoryPrice != null
          ? SubscriptionTrialInfo(
              price: product.introductoryPrice!.price,
              priceString: product.introductoryPrice!.priceString,
              period: product.introductoryPrice!.period,
              currencyCode: product.currencyCode,
            )
          : null,
    );
  }

  SubscriptionPackage? _findMatchedPackage(
    String? productIdentifier,
    String? productPlanIdentifier,
    List<SubscriptionPackage> packages,
  ) {
    final purchasedId = Platform.isAndroid ? (productPlanIdentifier ?? productIdentifier) : productIdentifier;
    if (purchasedId == null) return null;
    try {
      return packages.firstWhere(
        (p) => p.productIdentifier == purchasedId || p.id == purchasedId,
      );
    } catch (_) {
      return null;
    }
  }

  SubscriptionEntity? _mapCustomerInfo(
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

  @override
  Future<Result<SubscriptionOfferings>> getOfferings() async {
    try {
      final offerings = await makeRequest(
        Purchases.getOfferings,
        label: 'getOfferings',
        transformError: _transformRevenueCatError,
      );
      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return const Result.success(SubscriptionOfferings(packages: []));
      }
      final packages = current.availablePackages.map(_mapPackage).toList();
      return Result.success(
        SubscriptionOfferings(
          packages: packages,
          currentOfferingId: current.identifier,
        ),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<SubscriptionEntity?>> purchasePackage(
    SubscriptionPackage package,
  ) async {
    try {
      final offerings = await makeRequest(
        Purchases.getOfferings,
        label: 'getOfferings',
        transformError: _transformRevenueCatError,
      );
      final current = offerings.current;
      final rcPackage = _findPackageById(offerings, package.id);
      if (rcPackage == null) {
        return Result.error(
          Exception('Package ${package.id} not found in offerings'),
        );
      }
      final result = await makeRequest(
        () => Purchases.purchase(PurchaseParams.package(rcPackage)),
        label: 'purchasePackage',
        transformError: _transformRevenueCatError,
      );
      final packages = current?.availablePackages.map(_mapPackage).toList() ?? [];
      return Result.success(_mapCustomerInfo(result.customerInfo, packages: packages));
    } on PurchaseCancelledException {
      return const Result.error(PurchaseCancelledException());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<SubscriptionEntity?>> getCurrentSubscription({
    List<SubscriptionPackage>? packages,
  }) async {
    try {
      final info = await makeRequest(
        Purchases.getCustomerInfo,
        label: 'getCurrentSubscription',
        transformError: _transformRevenueCatError,
      );
      return Result.success(_mapCustomerInfo(info, packages: packages));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<SubscriptionEntity?>> restorePurchases({
    List<SubscriptionPackage>? packages,
  }) async {
    try {
      final info = await makeRequest(
        Purchases.restorePurchases,
        label: 'restorePurchases',
        transformError: _transformRevenueCatError,
      );
      return Result.success(_mapCustomerInfo(info, packages: packages));
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
