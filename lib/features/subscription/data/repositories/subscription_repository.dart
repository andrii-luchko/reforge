import 'package:injectable/injectable.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/network/repository_error_handler.dart';
import 'package:reforge/features/subscription/data/mappers/revenue_cat_customer_info_mapper.dart';
import 'package:reforge/features/subscription/data/mappers/revenue_cat_package_mapper.dart';
import 'package:reforge/features/subscription/data/transformers/revenue_cat_error_transformer.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/features/subscription/domain/repositories/subscription_repository.dart' as domain;

@Injectable(as: domain.SubscriptionRepository)
class SubscriptionRepositoryImpl with RepositoryErrorHandler implements domain.SubscriptionRepository {
  @override
  Future<Result<SubscriptionOfferings>> getOfferings() async {
    try {
      final offerings = await makeRequest(
        Purchases.getOfferings,
        label: 'getOfferings',
        transformError: transformRevenueCatError,
      );

      final current = offerings.current;
      if (current == null || current.availablePackages.isEmpty) {
        return const Result.success(SubscriptionOfferings(packages: []));
      }
      final packages = current.availablePackages.map(mapPackage).toList();
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
        transformError: transformRevenueCatError,
      );
      final current = offerings.current;
      final rcPackage = findPackageById(offerings, package.id);
      if (rcPackage == null) {
        return Result.error(
          Exception('Package ${package.id} not found in offerings'),
        );
      }
      final result = await makeRequest(
        () => Purchases.purchase(PurchaseParams.package(rcPackage)),
        label: 'purchasePackage',
        transformError: transformRevenueCatError,
      );
      final packages = current?.availablePackages.map(mapPackage).toList() ?? [];
      return Result.success(mapCustomerInfo(result.customerInfo, packages: packages));
    } on PurchaseCancelledException {
      return const Result.error(PurchaseCancelledException());
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<SubscriptionEntity?>> getCurrentSubscription({
    List<SubscriptionPackage>? packages,
    String? fallbackRcPackageGroupId,
  }) async {
    try {
      final info = await makeRequest(
        Purchases.getCustomerInfo,
        label: 'getCurrentSubscription',
        transformError: transformRevenueCatError,
      );
      return Result.success(
        mapCustomerInfo(
          info,
          packages: packages,
          fallbackRcPackageGroupId: fallbackRcPackageGroupId,
        ),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<SubscriptionEntity?>> restorePurchases({
    List<SubscriptionPackage>? packages,
    String? fallbackRcPackageGroupId,
  }) async {
    try {
      final info = await makeRequest(
        Purchases.restorePurchases,
        label: 'restorePurchases',
        transformError: transformRevenueCatError,
      );
      return Result.success(
        mapCustomerInfo(
          info,
          packages: packages,
          fallbackRcPackageGroupId: fallbackRcPackageGroupId,
        ),
      );
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> login(int id) async {
    try {
      final user = await Purchases.getCustomerInfo();
      logger.d('${user.originalAppUserId} ==  $id: ${user.originalAppUserId == id.toString()}');
      if (user.originalAppUserId == id.toString()) {
        logger.d('revenueCat loginResult: same id, already up to date ');
        return const Result.success(null);
      }

      await makeRequest(
        () => Purchases.logIn(id.toString()),
        label: 'login',
        transformError: transformRevenueCatError,
      );

      logger.d('revenueCat loginResult: login completed');
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      final isAnonymous = await Purchases.isAnonymous;

      if (isAnonymous) return const Result.success(null);

      await makeRequest(
        Purchases.logOut,
        label: 'logout',
        transformError: transformRevenueCatError,
      );
      return const Result.success(null);
    } on Exception catch (e) {
      return Result.error(e);
    }
  }
}
