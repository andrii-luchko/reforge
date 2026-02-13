import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/auth/data/models/user.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/home/data/repository/home_repository.dart';
import 'package:reforge/features/home/domain/enum/stats_period.dart';
import 'package:reforge/features/home/domain/user_stats.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

part 'home_state.dart';
part 'home_cubit.freezed.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this._repository) : super(const HomeState());

  final HomeRepository _repository;

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true, error: null));

    await Future.wait([
      _loadUserData(),
      loadStatsByPeriod(state.period, isInitial: true),
    ]);

    emit(state.copyWith(isLoading: false));
  }

  Future<void> loadStatsByPeriod(StatsPeriod period, {bool isInitial = false}) async {
    if (!isInitial && state.statsMap.containsKey(period)) {
      emit(state.copyWith(period: period));
      return;
    }

    if (!isInitial) {
      emit(state.copyWith(isStatsLoading: true, period: period));
    }

    final statsResult = await _repository.getUserStats(period);

    switch (statsResult) {
      case Success(value: final stats):
        final updatedMap = Map<StatsPeriod, UserStats>.from(state.statsMap);
        updatedMap[period] = stats;

        final rank = _createRank(state.user, stats);

        emit(
          state.copyWith(
            statsMap: updatedMap,
            rank: rank,
            isStatsLoading: false,
          ),
        );

      case ErrorR(error: final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isStatsLoading: false,
          ),
        );
    }
  }

  Future<void> _loadUserData() async {
    final userResult = _repository.getUserData();
    if (userResult != null) {
      emit(state.copyWith(user: userResult));
    }
  }

  RankEntity _createRank(OnboardedUser? user, UserStats stats) {
    return RankEntity(
      imageUrl: Assets.images.png.avatar.path,
      rankName: t.tiers.intermediate,
      faction: user?.mainFaction ?? Faction.gakki,
      lvl: stats.level,
      xp: stats.currentXp,
      maxXp: stats.totalXp,
    );
  }

  void changePeriod(StatsPeriod period) => loadStatsByPeriod(period);
}
