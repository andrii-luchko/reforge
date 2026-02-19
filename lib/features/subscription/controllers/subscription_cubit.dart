import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_period_type.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/features/subscription/domain/repositories/subscription_repository.dart' as domain;

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

@injectable
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._repository) : super(const SubscriptionState()) {
    unawaited(loadOfferings());
  }

  final domain.SubscriptionRepository _repository;

  Future<void> loadOfferings() async {
    emit(state.copyWith(isLoading: true, error: null));

    final offeringsResult = await _repository.getOfferings();
    SubscriptionEntity? currentSubscription;
    switch (offeringsResult) {
      case Success(value: final offerings):
        final subscriptionResult = await _repository.getCurrentSubscription(
          packages: offerings.packages,
        );
        switch (subscriptionResult) {
          case Success(value: final sub):
            currentSubscription = sub;
          case ErrorR():
            break;
        }
        emit(
          state.copyWith(
            offerings: offerings,
            currentSubscription: currentSubscription,
            isLoading: false,
          ),
        );
      case ErrorR(error: final error):
        emit(
          state.copyWith(
            error: 'Failed to load offerings: $error',
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
      case ErrorR(error: final error):
        if (error is PurchaseCancelledException) {
          emit(state.copyWith(isPurchasing: false));
        } else {
          emit(
            state.copyWith(
              error: 'Purchase failed: $error',
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
    );

    switch (result) {
      case Success(value: final subscription):
        if (state.offerings != null) {
          emit(state.copyWith(currentSubscription: subscription));
        }
      case ErrorR():
        break;
    }
  }

  Future<void> restorePurchases() async {
    if (state.offerings == null) return;

    emit(state.copyWith(isPurchasing: true, error: null));

    final result = await _repository.restorePurchases(
      packages: state.offerings!.packages,
    );

    switch (result) {
      case Success(value: final subscription):
        emit(
          state.copyWith(
            currentSubscription: subscription,
            isPurchasing: false,
          ),
        );
      case ErrorR(error: final error):
        emit(
          state.copyWith(
            error: 'Restore failed: $error',
            isPurchasing: false,
          ),
        );
    }
  }
}
