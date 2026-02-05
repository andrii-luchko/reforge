import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/leaderboard/data/repositories/leaderboard_repository.dart';
import 'package:reforge/features/leaderboard/domain/entities/leaderboard_faction_model.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_mode.dart';
import 'package:reforge/features/leaderboard/domain/enum/faction_show_type.dart';
import 'package:reforge/features/leaderboard/domain/helpers/generate_mock_factions.dart';
import 'package:reforge/features/quiz/domain/enums/faction.dart';

part 'factions_leaderboard_state.dart';
part 'factions_leaderboard_cubit.freezed.dart';

@injectable
class FactionsLeaderboardCubit extends Cubit<FactionsLeaderboardState> {
  FactionsLeaderboardCubit(this._repository) : super(const FactionsLeaderboardState()) {
    unawaited(loadFactions());
  }

  final LeaderboardRepositoryI _repository;

  Future<void> loadFactions() async {
    if (state.isLoading) return;
    final mocked = generateMockFactions();
    emit(state.copyWith(isLoading: true, error: null, factions: mocked));

    final userFaction = _repository.getUserFaction();
    final result = await _repository.getFactionsLeaderboard();

    switch (result) {
      case Success(value: final factions):
        emit(state.copyWith(factions: factions, userFaction: userFaction, isLoading: false));
      case Error(error: final error):
        emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  void changeMode(FactionMode mode) {
    emit(state.copyWith(selectedMode: mode));
  }

  void changeShowType(FactionShowType type) {
    emit(state.copyWith(selectedType: type));
  }
}
