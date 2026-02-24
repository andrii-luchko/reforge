import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';

abstract interface class SubscriptionRepository {
  Future<Result<void>> login(int id);
  Future<Result<void>> logout();
  Future<Result<SubscriptionOfferings>> getOfferings();
  Future<Result<SubscriptionEntity?>> purchasePackage(SubscriptionPackage package);
  Future<Result<SubscriptionEntity?>> getCurrentSubscription({
    List<SubscriptionPackage>? packages,
  });

  Future<Result<SubscriptionEntity?>> restorePurchases({
    List<SubscriptionPackage>? packages,
  });
}
