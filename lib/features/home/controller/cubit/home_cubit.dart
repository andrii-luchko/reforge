import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/achievements/domain/enums/rank.dart';
import 'package:reforge/features/home/data/repository/home_repository.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository, this._analytics) : super(const HomeState());

  final HomeRepository _repository;
  final AnalyticsService _analytics;

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, error: null));

    _loadUserData();

    try {
      await loadStatsByPeriod(state.period, isInitial: true);
      // ignore: avoid_catches_without_on_clauses
    } catch (error) {
      emit(
        state.copyWith(
          error: error.toString(),
        ),
      );
    } finally {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _loadUserData() {
    final userResult = _repository.getUserData();
    if (userResult != null) {
      emit(state.copyWith(user: userResult));
    }
  }

  Future<void> loadStatsByPeriod(StatsPeriod period, {bool isInitial = false}) async {
    // if (!isInitial && state.statsMap.containsKey(period)) {
    //   emit(state.copyWith(period: period));
    //   return;
    // }

    if (!isInitial) {
      emit(state.copyWith(isStatsLoading: true, period: period));
    }

    final statsResult = await _repository.getUserStats(period);

    switch (statsResult) {
      case Success(value: final stats):
        final updatedMap = Map<StatsPeriod, UserStats>.from(state.statsMap);
        if (stats != null) {
          updatedMap[period] = stats;
        }

        final rank = _createRank(state.user, stats);

        emit(
          state.copyWith(
            statsMap: updatedMap,
            rank: rank,
            isStatsLoading: false,
          ),
        );

      case Failure(:final error):
        final rank = _createRank(state.user);
        emit(
          state.copyWith(
            error: error.toString(),
            rank: rank,
            isStatsLoading: false,
          ),
        );
    }
  }

  RankEntity _createRank(OnboardedUser? user, [UserStats? stats]) {
    final faction = user?.mainFaction ?? Faction.gakki;
    final japanRankName = user?.japanRank ?? t.home.default_japanese_rank_name;
    final rankName = user?.rank ?? t.home.default_rank_name;
    final rank = Rank.fromJapaneseString(japanRankName);
    if (stats != null) {
      return RankEntity(
        imageAsset: rank.imageAsset(faction),
        japanRankName: japanRankName,
        rankName: rankName,
        faction: faction,
        lvl: stats.level,
        xp: stats.currentXp,
        maxXp: stats.totalXp,
      );
    } else {
      return RankEntity.mock(faction);
    }
  }

  void changePeriod(StatsPeriod period) {
    unawaited(
      _analytics.logEvent(
        AnalyticsEvents.homeStatsPeriodChange,
        {'period': period.name},
      ),
    );
    unawaited(loadStatsByPeriod(period));
  }

  void onStartWorkoutTap() {
    unawaited(_analytics.logEvent(AnalyticsEvents.homeStartWorkoutClick));
  }
}
