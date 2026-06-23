import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/achievements/data/repositories/achievements_repository.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'achievements_state.dart';
part 'achievements_cubit.freezed.dart';

@injectable
class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit(this._repository, this._analytics) : super(const AchievementsState());

  final AchievementsRepository _repository;
  final AnalyticsService _analytics;

  Future<void> init() async {
    setUserFaction();
    await loadAttributes();
    await loadBadges();
  }

  void setUserFaction() {
    final userFaction = _repository.getUserFaction();

    if (userFaction != null) {
      emit(state.copyWith(selectedFaction: userFaction));
    }
  }

  Future<void> loadAttributes({bool forceRefresh = false}) async {
    if (state.isLoading || (state.attributes.isNotEmpty && !forceRefresh)) return;

    emit(state.copyWith(isLoading: true, error: null));

    final result = await _repository.getUserAttributes();

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

    final result = await _repository.getUserBadges();
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

    final result = await _repository.getUserRanks(faction);
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
        imageUrl: rank.imageUrl,
        japanRankName: rank.japanRankName,
        rankName: rank.rankName,
        faction: rank.faction,
        lvl: currentRank.lvl,
        xp: currentRank.xp,
        maxXp: currentRank.maxXp,
      );
    }).toList();
  }
}
