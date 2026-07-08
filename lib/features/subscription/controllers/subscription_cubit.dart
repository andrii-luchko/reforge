import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/features/subscription/domain/repositories/subscription_repository.dart' as domain;
import 'package:reforge/generated/i18n/translations.g.dart';

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

@injectable
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._repository, this._userCubit) : super(const SubscriptionState()) {
    _userSubscription = _userCubit.stream.listen(_onUserChanges);
  }

  final domain.SubscriptionRepository _repository;
  final UserCubit _userCubit;
  StreamSubscription<UserState>? _userSubscription;

  /// Cross-platform fallback: when subscription was bought on another platform,
  /// RC returns different productIdentifier; backend's rcPackageGroupId allows
  /// matching to the correct package in current platform offerings.
  String? get _fallbackRcPackageGroupId {
    final user = _userCubit.state.userOrNull;
    if (user case OnboardedUser(subscription: final sub?)) {
      return sub.package.rcPackageGroupId;
    }
    return null;
  }

  Future<void> _onUserChanges(UserState state) async {
    await state.maybeMap(
      loaded: (value) async {
        await _repository.login(value.user.id);
        await loadOfferings();
      },
      initial: (value) => _repository.logout(),
      deleted: (value) => _repository.logout(),
      orElse: () {},
    );
  }

  Future<void> loadOfferings() async {
    emit(state.copyWith(isLoading: true, error: null));

    final offeringsResult = await _repository.getOfferings();
    SubscriptionEntity? currentSubscription;
    switch (offeringsResult) {
      case Success(value: final offerings):
        final subscriptionResult = await _repository.getCurrentSubscription(
          packages: offerings.packages,
          fallbackRcPackageGroupId: _fallbackRcPackageGroupId,
        );
        switch (subscriptionResult) {
          case Success(value: final sub):
            currentSubscription = sub;
          case Failure():
            break;
        }
        emit(
          state.copyWith(
            offerings: offerings,
            currentSubscription: currentSubscription,
            isLoading: false,
          ),
        );
      case Failure(:final error):
        emit(
          state.copyWith(
            error: t.subscription.loadOfferingsError(error: error.toString()),
            isLoading: false,
          ),
        );
    }
  }

  Future<void> purchase(SubscriptionPackage package) async {
    final current = state;
    if (current.offerings == null) return;

    emit(state.copyWith(isPurchasing: true));

    final result = await _repository.purchasePackage(package);

    switch (result) {
      case Success(value: final subscription):
        emit(
          state.copyWith(
            currentSubscription: subscription,
            isPurchasing: false,
          ),
        );

        logger.d('Subscription purchased: $subscription');
      case Failure(:final error):
        if (error is PurchaseCancelledException) {
          emit(state.copyWith(isPurchasing: false));
        } else {
          emit(
            state.copyWith(
              error: t.subscription.purchaseFailed(error: error.toString()),
              isPurchasing: false,
            ),
          );
        }
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> checkSubscriptionStatus() async {
    final result = await _repository.getCurrentSubscription(
      packages: state.offerings?.packages,
      fallbackRcPackageGroupId: _fallbackRcPackageGroupId,
    );

    switch (result) {
      case Success(value: final subscription):
        if (state.offerings != null) {
          emit(state.copyWith(currentSubscription: subscription));
        }
      case Failure():
        break;
    }
  }

  Future<void> restorePurchases() async {
    if (state.offerings == null) return;

    emit(state.copyWith(isPurchasing: true, error: null));

    final result = await _repository.restorePurchases(
      packages: state.offerings!.packages,
      fallbackRcPackageGroupId: _fallbackRcPackageGroupId,
    );

    switch (result) {
      case Success(value: final subscription):
        emit(
          state.copyWith(
            currentSubscription: subscription,
            isPurchasing: false,
          ),
        );
      case Failure(:final error):
        emit(
          state.copyWith(
            error: t.subscription.restoreFailed(error: error.toString()),
            isPurchasing: false,
          ),
        );
    }
  }

  @override
  Future<void> close() {
    unawaited(_userSubscription?.cancel());
    return super.close();
  }
}
