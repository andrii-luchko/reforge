import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/immortal_forges_entity.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'immortal_forges_state.dart';
part 'immortal_forges_cubit.freezed.dart';

@injectable
class ImmortalForgesCubit extends Cubit<ImmortalForgesState> {
  ImmortalForgesCubit(this._repository) : super(const ImmortalForgesState()) {
    unawaited(init());
  }

  final LeaderboardRepositoryI _repository;

  Future<void> init() async {
    final userFaction = _repository.getUserFaction() ?? Faction.gakki;

    emit(state.copyWith(selectedFaction: userFaction, error: null));

    await _fetchData(userFaction);
  }

  Future<void> changeFaction(Faction faction) async {
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

    final result = await _repository.getImmortalForgesForFaction(faction);

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

      case Error(error: final error):
        emit(
          state.copyWith(
            isLoading: false,
            error: error.toString(),
          ),
        );
    }
  }
}
