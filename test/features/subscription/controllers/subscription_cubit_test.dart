import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/features/subscription/controllers/subscription_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';

import '../../../core/user/mocks/mock_user_cubit.dart';
import '../mocks/mock_subscription_repository.dart';

const package = SubscriptionPackage(
  id: 'monthly',
  title: 'Monthly',
  price: 9.99,
  priceString: r'$9.99',
  currencyCode: 'USD',
  periodType: SubscriptionPeriodType.monthly,
);
const offerings = SubscriptionOfferings(packages: [package]);
const activeSubscription = SubscriptionEntity();

OnboardedUser user(int id) => OnboardedUser(
  id: id,
  measurementSystem: MeasurementSystem.metric,
  factionId: 1,
  birthDate: DateTime(1990),
  workoutsPerWeek: 3,
);

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 10));

void main() {
  late MockSubscriptionRepository repository;
  late MockUserCubit userCubit;
  late StreamController<UserState> users;
  late StreamController<SubscriptionEntity?> updates;
  SubscriptionCubit? cubit;

  setUpAll(() => registerFallbackValue(package));

  setUp(() {
    repository = MockSubscriptionRepository();
    userCubit = MockUserCubit();
    users = StreamController<UserState>.broadcast();
    updates = StreamController<SubscriptionEntity?>.broadcast();
    when(() => userCubit.state).thenReturn(const UserState.initial());
    when(() => userCubit.stream).thenAnswer((_) => users.stream);
    when(() => repository.subscriptionUpdates).thenAnswer((_) => updates.stream);
    when(() => repository.login(any())).thenAnswer((_) async => const Result.success(null));
    when(() => repository.logout()).thenAnswer((_) async => const Result.success(null));
    when(() => repository.getOfferings()).thenAnswer((_) async => const Result.success(offerings));
    when(() => repository.getCurrentSubscription()).thenAnswer((_) async => const Result.success(null));
  });

  tearDown(() async {
    await cubit?.close();
    await users.close();
    await updates.close();
    cubit = null;
  });

  test('active access loads when offerings fail', () async {
    when(() => repository.getOfferings()).thenAnswer((_) async => Result.error(Exception('offline')));
    when(() => repository.getCurrentSubscription()).thenAnswer((_) async => const Result.success(activeSubscription));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();

    expect(cubit!.state.hasActiveSubscription, isTrue);
    expect(cubit!.state.offerings, isNull);
    verify(() => repository.getCurrentSubscription()).called(1);
  });

  test('user change clears previous access before RevenueCat login finishes', () async {
    final secondLogin = Completer<Result<void>>();
    when(() => repository.login(2)).thenAnswer((_) => secondLogin.future);
    when(() => repository.getCurrentSubscription()).thenAnswer((_) async => const Result.success(activeSubscription));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    expect(cubit!.state.hasActiveSubscription, isTrue);

    users.add(UserState.loaded(user(2)));
    await settle();
    expect(cubit!.state.accessStatus, SubscriptionAccessStatus.checking);
    expect(cubit!.state.currentSubscription, isNull);

    secondLogin.complete(const Result.success(null));
    await settle();
  });

  test('failed RevenueCat login does not load another account access', () async {
    when(() => repository.login(1)).thenAnswer((_) async => Result.error(Exception('login failed')));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();

    expect(cubit!.state.accessStatus, SubscriptionAccessStatus.error);
    verifyNever(() => repository.getCurrentSubscription());
    verifyNever(() => repository.getOfferings());
  });

  test('listener updates access without offerings', () async {
    when(() => repository.getOfferings()).thenAnswer((_) async => Result.error(Exception('offline')));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    updates.add(activeSubscription);
    await settle();

    expect(cubit!.state.hasActiveSubscription, isTrue);
    expect(cubit!.state.offerings, isNull);
  });

  test('purchase activates access from returned CustomerInfo', () async {
    when(() => repository.purchasePackage(package)).thenAnswer((_) async => const Result.success(activeSubscription));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    await cubit!.purchase(package);

    expect(cubit!.state.hasActiveSubscription, isTrue);
    expect(cubit!.state.isPurchasing, isFalse);
  });

  test('purchase without active entitlement keeps paywall', () async {
    when(() => repository.purchasePackage(package)).thenAnswer((_) async => const Result.success(null));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    await cubit!.purchase(package);

    expect(cubit!.state.accessStatus, SubscriptionAccessStatus.inactive);
    expect(cubit!.state.error, isNotNull);
  });

  test('restore activates access without offerings', () async {
    when(() => repository.getOfferings()).thenAnswer((_) async => Result.error(Exception('offline')));
    when(() => repository.restorePurchases()).thenAnswer((_) async => const Result.success(activeSubscription));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    await cubit!.restorePurchases();

    expect(cubit!.state.hasActiveSubscription, isTrue);
  });

  test('status failure does not imply inactive access', () async {
    when(() => repository.getCurrentSubscription()).thenAnswer((_) async => Result.error(Exception('offline')));
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();

    expect(cubit!.state.accessStatus, SubscriptionAccessStatus.error);
    expect(cubit!.state.hasActiveSubscription, isFalse);
  });

  test('older status response cannot overwrite a newer one', () async {
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();

    final first = Completer<Result<SubscriptionEntity?>>();
    final second = Completer<Result<SubscriptionEntity?>>();
    var calls = 0;
    when(() => repository.getCurrentSubscription()).thenAnswer((_) => ++calls == 1 ? first.future : second.future);

    final firstCheck = cubit!.checkSubscriptionStatus();
    final secondCheck = cubit!.checkSubscriptionStatus();
    second.complete(const Result.success(activeSubscription));
    await secondCheck;
    first.complete(const Result.success(null));
    await firstCheck;

    expect(cubit!.state.hasActiveSubscription, isTrue);
  });

  test('identity operations stay ordered during rapid account changes', () async {
    final firstLogin = Completer<Result<void>>();
    when(() => repository.login(1)).thenAnswer((_) => firstLogin.future);
    cubit = SubscriptionCubit(repository, userCubit);
    users.add(UserState.loaded(user(1)));
    await settle();
    users.add(UserState.loaded(user(2)));
    await settle();
    verifyNever(() => repository.login(2));

    firstLogin.complete(const Result.success(null));
    await settle();
    verify(() => repository.login(2)).called(1);
  });
}
