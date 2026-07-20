import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'immortal_forges_state.dart';
part 'immortal_forges_cubit.freezed.dart';

@injectable
class ImmortalForgesCubit extends Cubit<ImmortalForgesState> {
  ImmortalForgesCubit(this._repository, this._analytics, this._userCubit) : super(const ImmortalForgesState()) {
    _lastUser = _userCubit.currentOnboardedUser;
    _userSubscription = _userCubit.onboardedUserChanges.listen((user) => unawaited(_onUserChanged(user)));
    unawaited(init());
  }

  final LeaderboardRepositoryI _repository;
  final AnalyticsService _analytics;
  final UserCubit _userCubit;
  StreamSubscription<OnboardedUser?>? _userSubscription;
  OnboardedUser? _lastUser;
  int _userRevision = 0;

  Future<void> init() async {
    final userFaction = _lastUser?.mainFaction ?? Faction.gakki;

    emit(state.copyWith(selectedFaction: userFaction, error: null));

    await _fetchData(userFaction);
  }

  Future<void> _onUserChanged(OnboardedUser? user) async {
    final previousUser = _lastUser;
    if (previousUser?.id != user?.id || previousUser?.factionId != user?.factionId) _userRevision++;
    _lastUser = user;

    if (user == null) {
      emit(const ImmortalForgesState());
      return;
    }

    final faction = user.mainFaction;
    if (faction == null) return;

    final identityChanged = previousUser != null && previousUser.id != user.id;
    final factionChanged = previousUser?.factionId != user.factionId;
    if (!identityChanged && !factionChanged) return;

    if (identityChanged) {
      emit(ImmortalForgesState(selectedFaction: faction));
    } else {
      emit(state.copyWith(selectedFaction: faction, error: null));
    }

    if (!state.forgeData.containsKey(faction)) {
      await _fetchData(faction);
    }
  }

  Future<void> changeFaction(Faction faction) async {
    unawaited(_analytics.logEvent(AnalyticsEvents.leaderboardUsersFactionChange, {'faction': faction.name}));
    emit(state.copyWith(selectedFaction: faction, error: null));

    if (!state.forgeData.containsKey(faction)) {
      await _fetchData(faction);
    }
  }

  Future<void> refresh() async {
    await _fetchData(state.selectedFaction);
  }

  Future<void> _fetchData(Faction faction) async {
    emit(state.copyWith(isLoading: true, error: null));

    final revision = _userRevision;
    final result = await _repository.getImmortalForgesForFaction(faction);
    if (revision != _userRevision) return;

    switch (result) {
      case Success(value: final response):
        final leaders = response;

        final updatedData = Map<Faction, List<ImmortalForgeEntity>>.from(state.forgeData);
        updatedData[faction] = leaders;

        emit(
          state.copyWith(
            isLoading: false,
            forgeData: updatedData,
          ),
        );

      case Failure(:final error):
        emit(
          state.copyWith(
            isLoading: false,
            error: error.toString(),
          ),
        );
    }
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
