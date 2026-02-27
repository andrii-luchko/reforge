import 'package:reforge/app/utils/exceptions/app_exception.dart';

/// Thrown when the user cancels the purchase flow.
class PurchaseCancelledException implements AppException {
  const PurchaseCancelledException();

  @override
  String get message => '';
}
