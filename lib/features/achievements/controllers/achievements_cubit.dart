import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
import 'package:reforge/features/achievements/data/repositories/achievements_repository.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'achievements_state.dart';
part 'achievements_cubit.freezed.dart';

@injectable
class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit(this._repository, this._analytics, this._userCubit) : super(const AchievementsState()) {
    unawaited(_onUserChanged(_userCubit.currentOnboardedUser));
    _userSubscription = _userCubit.onboardedUserChanges.listen((user) => unawaited(_onUserChanged(user)));
  }

  final AchievementsRepository _repository;
  final AnalyticsService _analytics;
  final UserCubit _userCubit;
  StreamSubscription<OnboardedUser?>? _userSubscription;
  OnboardedUser? _lastUser;
  int _userRevision = 0;

  Future<void> init() async {
    setUserFaction();
    await loadAttributes();
    await loadBadges();
  }

  void setUserFaction() {
    final userFaction = _userCubit.currentOnboardedUser?.mainFaction;

    if (userFaction != null) {
      emit(state.copyWith(selectedFaction: userFaction));
    }
  }

  Future<void> _onUserChanged(OnboardedUser? user) async {
    final previousUser = _lastUser;
    if (previousUser?.id != user?.id) _userRevision++;
    _lastUser = user;

    if (user == null) {
      emit(const AchievementsState());
      return;
    }

    final faction = user.mainFaction;
    if (faction == null) return;

    if (previousUser != null && previousUser.id != user.id) {
      emit(AchievementsState(selectedFaction: faction));
      return;
    }

    if (state.selectedFaction == faction) return;
    final ranksWereOpened = state.ranks.isNotEmpty;
    emit(state.copyWith(selectedFaction: faction));

    if (ranksWereOpened && state.selectedRanks.isEmpty) {
      await loadRanks();
    }
  }

  Future<void> loadAttributes({bool forceRefresh = false}) async {
    if (state.isLoading || (state.attributes.isNotEmpty && !forceRefresh)) return;

    emit(state.copyWith(isLoading: true, error: null));

    final revision = _userRevision;
    final result = await _repository.getUserAttributes();
    if (revision != _userRevision) return;

    switch (result) {
      case Success(value: final attributes):
        emit(
          state.copyWith(
            attributes: attributes,
            isLoading: false,
          ),
        );
      case Failure(:final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  Future<void> loadBadges({bool forceRefresh = false}) async {
    if (state.isLoading || (state.badges.isNotEmpty && !forceRefresh)) return;

    emit(state.copyWith(isLoading: true, error: null));

    final revision = _userRevision;
    final result = await _repository.getUserBadges();
    if (revision != _userRevision) return;
    switch (result) {
      case Success(value: final badges):
        emit(
          state.copyWith(
            badges: badges,
            isLoading: false,
          ),
        );
      case Failure(:final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  void onRefresh() {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsRefresh));
  }

  void onLearnMoreRanksClick() {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsLearnMoreRanksClick));
  }

  void onLearnMoreBadgesClick() {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsLearnMoreBadgesClick));
  }

  void onBadgesRefresh() {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsBadgesRefresh));
  }

  void onRanksRefresh() {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsRanksRefresh));
  }

  Future<void> changeFaction(Faction faction) async {
    unawaited(_analytics.logEvent(AnalyticsEvents.achievementsRanksFactionChange, {'faction': faction.name}));
    emit(state.copyWith(selectedFaction: faction));

    final hasData = state.ranks[faction]?.isNotEmpty ?? false;

    if (!hasData) {
      await loadRanks();
    }
  }

  Future<void> loadRanks({bool forceRefresh = false}) async {
    if (state.isLoading || (state.selectedRanks.isNotEmpty && !forceRefresh)) return;

    emit(state.copyWith(isLoading: true, error: null));

    final faction = state.selectedFaction;

    final revision = _userRevision;
    final result = await _repository.getUserRanks(faction);
    if (revision != _userRevision) return;
    switch (result) {
      case Success(value: final newRanks):
        final updatedRanks = Map<Faction, List<RankEntity>>.from(state.ranks);
        updatedRanks[faction] = newRanks;

        emit(
          state.copyWith(
            ranks: updatedRanks,
            isLoading: false,
          ),
        );
      case Failure(:final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  List<RankEntity> mergeRanksWithCurrentProgress({
    required List<RankEntity> backendRanks,
    RankEntity? currentRank,
  }) {
    if (currentRank == null) return backendRanks;

    return backendRanks.map((rank) {
      final sameFaction = rank.faction == currentRank.faction;
      final sameName = rank.rankName == currentRank.rankName;

      if (!sameFaction || !sameName) return rank;

      return RankEntity(
        imageAsset: rank.imageAsset,
        japanRankName: rank.japanRankName,
        rankName: rank.rankName,
        faction: rank.faction,
        lvl: currentRank.lvl,
        xp: currentRank.xp,
        maxXp: currentRank.maxXp,
      );
    }).toList();
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
