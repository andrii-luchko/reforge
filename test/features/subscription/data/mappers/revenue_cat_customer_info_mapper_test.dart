import 'package:flutter_test/flutter_test.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:reforge/features/subscription/data/mappers/revenue_cat_customer_info_mapper.dart';

const premium = EntitlementInfo(
  reforgePremiumEntitlementId,
  true,
  true,
  '2026-09-22T00:00:00Z',
  '2026-09-01T00:00:00Z',
  'premium-product',
  false,
  expirationDate: '2026-10-22T00:00:00Z',
);

const other = EntitlementInfo(
  'Other entitlement',
  true,
  true,
  '2026-09-22T00:00:00Z',
  '2026-09-01T00:00:00Z',
  'other-product',
  false,
  expirationDate: '2026-09-30T00:00:00Z',
);

CustomerInfo customerInfo(Map<String, EntitlementInfo> active) => CustomerInfo(
  EntitlementInfos(active, active),
  const {},
  const [],
  const [],
  const [],
  '2026-09-01T00:00:00Z',
  'user-1',
  const {},
  '2026-09-22T00:00:00Z',
);

void main() {
  test('uses Reforge Premium even when another entitlement is first', () {
    final info = customerInfo({other.identifier: other, premium.identifier: premium});

    expect(mapCustomerInfo(info)?.expirationDate, DateTime.utc(2026, 10, 22));
  });

  test('does not grant access for another active entitlement', () {
    expect(mapCustomerInfo(customerInfo({other.identifier: other})), isNull);
  });
}
