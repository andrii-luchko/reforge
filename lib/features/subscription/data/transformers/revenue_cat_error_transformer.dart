import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

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

Exception? transformRevenueCatError(Object error, StackTrace _) {
  if (error is! PlatformException) return null;
  final code = PurchasesErrorHelper.getErrorCode(error);
  if (code == PurchasesErrorCode.purchaseCancelledError) {
    return const PurchaseCancelledException();
  }
  return Exception(_revenueCatToUserMessage(code));
}
