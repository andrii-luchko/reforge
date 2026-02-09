import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/achievements/data/repositories/achievements_repository.dart';
import 'package:reforge/features/achievements/domain/entities/attribute_entity.dart';
import 'package:reforge/features/achievements/domain/entities/badge_entity.dart';
import 'package:reforge/features/achievements/domain/entities/rank_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'achievements_state.dart';
part 'achievements_cubit.freezed.dart';

@injectable
class AchievementsCubit extends Cubit<AchievementsState> {
  AchievementsCubit(this._repository) : super(const AchievementsState());

  final AchievementsRepository _repository;

  Future<void> init() async {
    if (state.attributes.isNotEmpty) return;

    await loadAttributes();
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
      case Error(error: final error):
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
      case Error(error: final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }

  Future<void> changeFaction(Faction faction) async {
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
      case Error(error: final error):
        emit(
          state.copyWith(
            error: error.toString(),
            isLoading: false,
          ),
        );
    }
  }
}
