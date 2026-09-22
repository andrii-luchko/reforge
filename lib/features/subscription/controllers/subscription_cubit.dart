import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_entity.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_offerings.dart';
import 'package:reforge/features/subscription/domain/entity/subscription_package.dart';
import 'package:reforge/features/subscription/domain/exceptions/purchase_cancelled_exception.dart';
import 'package:reforge/features/subscription/domain/repositories/subscription_repository.dart' as domain;
import 'package:reforge/generated/i18n/translations.g.dart';

part 'subscription_cubit.freezed.dart';
part 'subscription_state.dart';

@injectable
class SubscriptionCubit extends Cubit<SubscriptionState> {
  SubscriptionCubit(this._repository, this._userCubit) : super(const SubscriptionState()) {
    unawaited(_onUserChanges(_userCubit.state));
    _userSubscription = _userCubit.stream.listen((state) => unawaited(_onUserChanges(state)));
    _subscriptionUpdatesSubscription = _repository.subscriptionUpdates.listen(_onSubscriptionUpdated);
  }

  final domain.SubscriptionRepository _repository;
  final UserCubit _userCubit;
  StreamSubscription<UserState>? _userSubscription;
  StreamSubscription<SubscriptionEntity?>? _subscriptionUpdatesSubscription;
  int? _lastUserId;
  int _userRevision = 0;
  int _statusRevision = 0;
  bool _identityReady = false;
  Future<void> _identityOperation = Future<void>.value();

  Future<void> _onUserChanges(UserState userState) async {
    final userId = switch (userState) {
      Loaded(:final user) => user.id,
      Initial() || Deleted() => null,
      _ => _lastUserId,
    };

    if (userId == _lastUserId) return;
    final previous = _lastUserId;
    _lastUserId = userId;
    final revision = ++_userRevision;
    _statusRevision++;
    _identityReady = false;
    emit(const SubscriptionState());

    final operation = _identityOperation.then((_) async {
      if (revision != _userRevision) return;
      if (userId == null) {
        if (previous != null) await _repository.logout();
      } else {
        await _connectUser(userId, revision);
      }
    });
    _identityOperation = operation;
    await operation;
  }

  Future<void> _connectUser(int userId, int revision) async {
    final loginResult = await _repository.login(userId);
    if (revision != _userRevision) return;
    if (loginResult case Failure(:final error)) {
      emit(state.copyWith(accessStatus: SubscriptionAccessStatus.error, error: error.toString()));
      return;
    }
    _identityReady = true;
    unawaited(loadOfferings());
    unawaited(checkSubscriptionStatus());
  }

  Future<void> retry() async {
    if (!_identityReady) {
      final userId = _lastUserId;
      if (userId == null) return;
      emit(state.copyWith(accessStatus: SubscriptionAccessStatus.checking, error: null));
      final revision = _userRevision;
      final operation = _identityOperation.then((_) async {
        if (revision == _userRevision) await _connectUser(userId, revision);
      });
      _identityOperation = operation;
      await operation;
      return;
    }
    await Future.wait([loadOfferings(), checkSubscriptionStatus()]);
  }

  void _onSubscriptionUpdated(SubscriptionEntity? subscription) {
    if (!_identityReady) return;
    _statusRevision++;
    emit(
      state.copyWith(
        currentSubscription: subscription,
        accessStatus: subscription != null
            ? SubscriptionAccessStatus.active
            : SubscriptionAccessStatus.inactive,
      ),
    );
  }

  Future<void> loadOfferings() async {
    final revision = _userRevision;
    emit(state.copyWith(isLoading: true, error: null));

    final offeringsResult = await _repository.getOfferings();
    if (revision != _userRevision) return;
    switch (offeringsResult) {
      case Success(value: final offerings):
        emit(
          state.copyWith(
            offerings: offerings,
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
    if (current.offerings == null || current.isPurchasing || current.hasActiveSubscription) return;

    final revision = _userRevision;
    emit(state.copyWith(isPurchasing: true));

    final result = await _repository.purchasePackage(package);
    if (revision != _userRevision) return;

    switch (result) {
      case Success(value: final subscription) when subscription != null:
        _statusRevision++;
        emit(
          state.copyWith(
            currentSubscription: subscription,
            accessStatus: SubscriptionAccessStatus.active,
            isPurchasing: false,
          ),
        );

        logger.d('Subscription purchased: $subscription');
        return;
      case Success():
        emit(state.copyWith(error: t.subscription.activationPending, isPurchasing: false));
        return;
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
        return;
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  Future<void> checkSubscriptionStatus() async {
    if (!_identityReady) return;
    final revision = _userRevision;
    final statusRevision = ++_statusRevision;
    final result = await _repository.getCurrentSubscription();
    if (revision != _userRevision || statusRevision != _statusRevision) return;

    switch (result) {
      case Success(value: final subscription):
        emit(
          state.copyWith(
            currentSubscription: subscription,
            accessStatus: subscription != null
                ? SubscriptionAccessStatus.active
                : SubscriptionAccessStatus.inactive,
          ),
        );
      case Failure():
        if (state.accessStatus == SubscriptionAccessStatus.checking) {
          emit(state.copyWith(accessStatus: SubscriptionAccessStatus.error));
        }
    }
  }

  Future<void> restorePurchases() async {
    if (!_identityReady || state.isPurchasing) return;

    final revision = _userRevision;
    emit(state.copyWith(isPurchasing: true, error: null));

    final result = await _repository.restorePurchases();
    if (revision != _userRevision) return;

    switch (result) {
      case Success(value: final subscription):
        _statusRevision++;
        emit(
          state.copyWith(
            currentSubscription: subscription,
            accessStatus: subscription != null
                ? SubscriptionAccessStatus.active
                : SubscriptionAccessStatus.inactive,
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
    unawaited(_subscriptionUpdatesSubscription?.cancel());
    return super.close();
  }
}
