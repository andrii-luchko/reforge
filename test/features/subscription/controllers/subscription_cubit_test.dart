import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import '../../../core/user/mocks/mock_user_cubit.dart';
import '../mocks/mock_subscription_repository.dart';

SubscriptionPackage createTestPackage({
  String id = 'monthly',
  String title = 'Monthly',
  double price = 9.99,
  String priceString = r'$9.99',
  String currencyCode = 'USD',
  SubscriptionPeriodType periodType = SubscriptionPeriodType.monthly,
}) {
  return SubscriptionPackage(
    id: id,
    title: title,
    price: price,
    priceString: priceString,
    currencyCode: currencyCode,
    periodType: periodType,
  );
}

SubscriptionOfferings createTestOfferings({
  List<SubscriptionPackage>? packages,
}) {
  return SubscriptionOfferings(
    packages: packages ?? [createTestPackage()],
    currentOfferingId: 'default',
  );
}

SubscriptionEntity createTestSubscription({bool isActive = true}) {
  return SubscriptionEntity(
    isActive: isActive,
    expirationDate: DateTime(2025, 12, 31),
    entitlementId: 'premium',
  );
}

void main() {
  late MockSubscriptionRepository mockRepository;
  late MockUserCubit mockUserCubit;
  setUpAll(() {
    registerFallbackValue(createTestPackage());
  });

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    mockUserCubit = MockUserCubit();
  });

  group('SubscriptionCubit', () {
    group('loadOfferings', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits loading then loaded when repository succeeds',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        act: (cubit) => cubit.loadOfferings(),
        expect: () => [
          const SubscriptionState(isLoading: true),
          isA<SubscriptionState>()
              .having((s) => s.offerings, 'offerings', isNotNull)
              .having(
                (s) => s.currentSubscription,
                'currentSubscription',
                isNotNull,
              )
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits loading then error when getOfferings fails',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.error(Exception('Network error')),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        act: (cubit) => cubit.loadOfferings(),
        expect: () => [
          const SubscriptionState(isLoading: true),
          isA<SubscriptionState>()
              .having((s) => s.error, 'error', contains('Failed to load offerings'))
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits loaded with null currentSubscription when getCurrentSubscription fails',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.error(Exception('Not found')),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        act: (cubit) => cubit.loadOfferings(),
        expect: () => [
          const SubscriptionState(isLoading: true),
          isA<SubscriptionState>()
              .having(
                (s) => s.offerings?.packages.length,
                'packages count',
                1,
              )
              .having(
                (s) => s.currentSubscription,
                'currentSubscription',
                isNull,
              )
              .having((s) => s.isLoading, 'isLoading', false),
        ],
      );
    });

    group('purchase', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'does nothing when state is not loaded',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.error(Exception('')),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => const SubscriptionState(),
        act: (cubit) => cubit.purchase(createTestPackage()),
        expect: () => <SubscriptionState>[],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits purchasing then loaded with updated subscription on success',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          when(() => mockRepository.purchasePackage(any())).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) => cubit.purchase(createTestPackage()),
        expect: () => [
          isA<SubscriptionState>()
              .having((s) => s.isPurchasing, 'isPurchasing', true)
              .having((s) => s.offerings, 'offerings', isNotNull),
          isA<SubscriptionState>()
              .having(
                (s) => s.currentSubscription?.isActive,
                'currentSubscription.isActive',
                true,
              )
              .having((s) => s.isPurchasing, 'isPurchasing', false),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits purchasing then loaded when user cancels',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          when(() => mockRepository.purchasePackage(any())).thenAnswer(
            (_) async => const Result.error(PurchaseCancelledException()),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) => cubit.purchase(createTestPackage()),
        expect: () => [
          isA<SubscriptionState>()
              .having((s) => s.isPurchasing, 'isPurchasing', true)
              .having((s) => s.offerings, 'offerings', isNotNull),
          isA<SubscriptionState>()
              .having(
                (s) => s.offerings?.packages.length,
                'packages count',
                1,
              )
              .having((s) => s.isPurchasing, 'isPurchasing', false),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'emits purchasing then error when purchase fails',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          when(() => mockRepository.purchasePackage(any())).thenAnswer(
            (_) async => Result.error(Exception('Payment failed')),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) => cubit.purchase(createTestPackage()),
        expect: () => [
          isA<SubscriptionState>()
              .having((s) => s.isPurchasing, 'isPurchasing', true)
              .having((s) => s.offerings, 'offerings', isNotNull),
          isA<SubscriptionState>()
              .having(
                (s) => s.error,
                'error',
                contains('Purchase failed'),
              )
              .having((s) => s.isPurchasing, 'isPurchasing', false),
        ],
      );
    });

    group('checkSubscriptionStatus', () {
      blocTest<SubscriptionCubit, SubscriptionState>(
        'updates currentSubscription when in loaded state',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.success(createTestSubscription()),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) => cubit.checkSubscriptionStatus(),
        expect: () => [
          isA<SubscriptionState>().having(
            (s) => s.currentSubscription?.isActive,
            'currentSubscription',
            true,
          ),
        ],
      );

      blocTest<SubscriptionCubit, SubscriptionState>(
        'does nothing when getCurrentSubscription fails',
        build: () {
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(createTestOfferings()),
          );
          when(() => mockRepository.getCurrentSubscription(packages: any(named: 'packages'))).thenAnswer(
            (_) async => Result.error(Exception('Error')),
          );
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) => cubit.checkSubscriptionStatus(),
        expect: () => <SubscriptionState>[],
      );
    });
  });
}
