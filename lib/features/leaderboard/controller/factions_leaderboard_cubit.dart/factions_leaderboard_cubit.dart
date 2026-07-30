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
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';

import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'factions_leaderboard_state.dart';
part 'factions_leaderboard_cubit.freezed.dart';

@injectable
class FactionsLeaderboardCubit extends Cubit<FactionsLeaderboardState> {
  FactionsLeaderboardCubit(this._repository, this._analytics, this._userCubit)
    : super(const FactionsLeaderboardState()) {
    _lastUser = _userCubit.currentOnboardedUser;
    final faction = _lastUser?.mainFaction;
    if (faction != null) emit(state.copyWith(userFaction: faction));
    _userSubscription = _userCubit.onboardedUserChanges.listen((user) => unawaited(_onUserChanged(user)));
    unawaited(loadFactions());
  }

  final LeaderboardRepositoryI _repository;
  final AnalyticsService _analytics;
  final UserCubit _userCubit;
  StreamSubscription<OnboardedUser?>? _userSubscription;
  OnboardedUser? _lastUser;

  Future<void> loadFactions() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getFactionsLeaderboard();
    final userFaction = _lastUser?.mainFaction;

    switch (result) {
      case Success(value: final factions):
        emit(state.copyWith(factions: factions, userFaction: userFaction, isLoading: false));
      case Failure(:final error):
        emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> _onUserChanged(OnboardedUser? user) async {
    final previousUser = _lastUser;
    _lastUser = user;

    if (user == null) {
      emit(const FactionsLeaderboardState());
      return;
    }

    final faction = user.mainFaction;
    if (faction == null || previousUser?.factionId == user.factionId) return;

    emit(state.copyWith(userFaction: faction));
  }

  void changeMode(FactionMode mode) {
    unawaited(_analytics.logEvent(AnalyticsEvents.leaderboardFactionsModeChange, {'mode': mode.name}));
    emit(state.copyWith(selectedMode: mode));
  }

  void changeShowType(FactionShowType type) {
    unawaited(_analytics.logEvent(AnalyticsEvents.leaderboardFactionsShowTypeChange, {'type': type.name}));
    setShowType(type);
  }

  void setShowType(FactionShowType type) {
    if (state.selectedType == type) return;
    emit(state.copyWith(selectedType: type));
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
