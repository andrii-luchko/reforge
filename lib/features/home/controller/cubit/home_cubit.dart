import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/core/user/controller/user_cubit.dart';
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
  HomeCubit(this._repository, this._analytics, this._userCubit) : super(const HomeState()) {
    _onUserChanged(_userCubit.currentOnboardedUser);
    _userSubscription = _userCubit.onboardedUserChanges.listen(_onUserChanged);
  }

  final HomeRepository _repository;
  final AnalyticsService _analytics;
  final UserCubit _userCubit;
  StreamSubscription<OnboardedUser?>? _userSubscription;
  OnboardedUser? _lastUser;
  int _userRevision = 0;

  Future<void> ensureInitialDataLoaded() async {
    if (state.isLoading) return;
    if (state.currentStats != null) return;

    await loadInitialData();
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, error: null));

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

  void _onUserChanged(OnboardedUser? user) {
    final previousUser = _lastUser;
    if (previousUser?.id != user?.id) _userRevision++;
    _lastUser = user;

    if (user == null) {
      emit(const HomeState());
      return;
    }

    if (previousUser != null && previousUser.id != user.id) {
      emit(HomeState(user: user));
      return;
    }

    final rankProfileChanged =
        previousUser == null ||
        previousUser.factionId != user.factionId ||
        previousUser.rank != user.rank ||
        previousUser.japanRank != user.japanRank;

    emit(
      state.copyWith(
        user: user,
        rank: rankProfileChanged
            ? _createRank(
                user,
                state.currentStats,
                previousRank: state.rank,
              )
            : state.rank,
      ),
    );
  }

  Future<void> loadStatsByPeriod(StatsPeriod period, {bool isInitial = false}) async {
    if (!isInitial && state.statsMap.containsKey(period)) {
      emit(
        state.copyWith(
          period: period,
          rank: _createRank(
            state.user,
            state.statsMap[period],
            previousRank: state.rank,
          ),
        ),
      );
      return;
    }

    if (!isInitial) {
      emit(state.copyWith(isStatsLoading: true, period: period));
    }

    final revision = _userRevision;
    final statsResult = await _repository.getUserStats(period);
    if (revision != _userRevision) return;

    switch (statsResult) {
      case Success(value: final stats):
        final updatedMap = Map<StatsPeriod, UserStats>.from(state.statsMap)..[period] = stats;
        final rank = _createRank(
          state.user,
          stats,
          previousRank: state.rank,
        );

        emit(
          state.copyWith(
            statsMap: updatedMap,
            rank: rank,
            isStatsLoading: false,
          ),
        );

      case Failure(:final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isStatsLoading: false,
          ),
        );
    }
  }

  Future<void> refreshAfterWorkout() async {
    emit(state.copyWith(statsMap: {}));
    await loadInitialData();
  }

  RankEntity? _createRank(
    OnboardedUser? user,
    UserStats? stats, {
    RankEntity? previousRank,
  }) {
    if (user == null) return previousRank;

    final faction = user.mainFaction ?? Faction.gakki;
    final japanRankName = user.japanRank ?? t.home.default_japanese_rank_name;
    final rankName = user.rank ?? t.home.default_rank_name;
    final rank = Rank.fromJapaneseString(japanRankName);
    if (stats == null && previousRank == null) return null;

    return RankEntity(
      imageAsset: rank.imageAsset(faction),
      japanRankName: japanRankName,
      rankName: rankName,
      faction: faction,
      lvl: stats?.level ?? previousRank?.lvl,
      xp: stats?.currentXp ?? previousRank?.xp,
      maxXp: stats?.xpGoal ?? previousRank?.maxXp,
    );
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

  void onFreeRunTap() {
    unawaited(_analytics.logEvent(AnalyticsEvents.homeFreeRunClick));
  }

  @override
  Future<void> close() async {
    await _userSubscription?.cancel();
    return super.close();
  }
}
