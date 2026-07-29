import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/core/user/data/models/user_subscription.dart' as user_model;
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
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

SubscriptionEntity createTestSubscription({
  bool isActive = true,
  SubscriptionPackage? matchedPackage,
}) {
  return SubscriptionEntity(
    isActive: isActive,
    expirationDate: DateTime(2025, 12, 31),
    entitlementId: 'premium',
    matchedPackage: matchedPackage,
  );
}

OnboardedUser createTestUser({user_model.UserSubscription? subscription, String? email}) => OnboardedUser(
  id: 1,
  email: email,
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
  subscription: subscription,
);

void main() {
  late MockSubscriptionRepository mockRepository;
  late MockUserCubit mockUserCubit;
  setUpAll(() {
    registerFallbackValue(createTestPackage());
  });

  setUp(() {
    mockRepository = MockSubscriptionRepository();
    mockUserCubit = MockUserCubit();
    when(() => mockRepository.subscriptionUpdates).thenAnswer((_) => const Stream.empty());
    when(() => mockUserCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockUserCubit.state).thenReturn(const UserState.initial());
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
        'currentPackage equals matchedPackage from subscription by id',
        build: () {
          final package = createTestPackage(id: 'annual', periodType: SubscriptionPeriodType.annual);
          final offerings = createTestOfferings(
            packages: [
              // ignore: avoid_redundant_argument_values
              createTestPackage(id: 'monthly'),
              package,
            ],
          );
          when(() => mockRepository.getOfferings()).thenAnswer(
            (_) async => Result.success(offerings),
          );
          when(
            () => mockRepository.getCurrentSubscription(packages: any(named: 'packages')),
          ).thenAnswer((_) async => Result.success(createTestSubscription(matchedPackage: package)));
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        act: (cubit) => cubit.loadOfferings(),
        expect: () => [
          const SubscriptionState(isLoading: true),
          isA<SubscriptionState>()
              .having((s) => s.currentPackage?.id, 'currentPackage.id', 'annual')
              .having((s) => s.hasActiveSubscription, 'hasActiveSubscription', true),
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

    group('subscriptionUpdates', () {
      late StreamController<SubscriptionEntity?> updates;

      blocTest<SubscriptionCubit, SubscriptionState>(
        'updates the current subscription from RevenueCat listener events',
        build: () {
          updates = StreamController<SubscriptionEntity?>();
          when(() => mockRepository.subscriptionUpdates).thenAnswer((_) => updates.stream);
          addTearDown(updates.close);
          return SubscriptionCubit(mockRepository, mockUserCubit);
        },
        seed: () => SubscriptionState(offerings: createTestOfferings()),
        act: (cubit) async {
          updates.add(createTestSubscription());
          await Future<void>.delayed(Duration.zero);
        },
        expect: () => [
          isA<SubscriptionState>().having(
            (state) => state.currentSubscription?.isActive,
            'currentSubscription.isActive',
            true,
          ),
        ],
      );
    });

    test('reacts only to identity and subscription changes', () async {
      final userChanges = StreamController<UserState>.broadcast();
      final initialUser = createTestUser(email: 'old@example.com');
      when(() => mockUserCubit.state).thenReturn(UserState.loaded(initialUser));
      when(() => mockUserCubit.stream).thenAnswer((_) => userChanges.stream);
      when(() => mockRepository.login(1)).thenAnswer((_) async => const Result.success(null));
      when(() => mockRepository.logout()).thenAnswer((_) async => const Result.success(null));
      when(() => mockRepository.getOfferings()).thenAnswer((_) async => Result.success(createTestOfferings()));
      when(
        () => mockRepository.getCurrentSubscription(packages: any(named: 'packages')),
      ).thenAnswer((_) async => const Result.success(null));

      final cubit = SubscriptionCubit(mockRepository, mockUserCubit);
      await Future<void>.delayed(Duration.zero);
      verify(() => mockRepository.login(1)).called(1);
      verify(() => mockRepository.getOfferings()).called(1);

      userChanges.add(UserState.loaded(initialUser.copyWith(email: 'new@example.com')));
      await Future<void>.delayed(Duration.zero);
      verifyNever(() => mockRepository.login(1));
      verifyNever(() => mockRepository.getOfferings());

      final subscription = user_model.UserSubscription(
        id: 10,
        isActive: true,
        expiresAt: DateTime(2030),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
        package: const user_model.Package(
          id: 5,
          name: 'Premium',
          rcProductId: 'premium',
          rcPackageGroupId: 'premium-group',
        ),
      );
      userChanges.add(UserState.loaded(initialUser.copyWith(subscription: subscription)));
      await Future<void>.delayed(Duration.zero);
      verify(() => mockRepository.getOfferings()).called(1);
      verifyNever(() => mockRepository.login(1));

      userChanges.add(const UserState.initial());
      await Future<void>.delayed(Duration.zero);
      verify(() => mockRepository.logout()).called(1);
      expect(cubit.state, const SubscriptionState());

      await cubit.close();
      await userChanges.close();
    });
  });
}
