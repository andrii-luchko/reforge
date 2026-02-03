import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/domain/mock/lore_mock_generator.dart';
import 'package:reforge/features/lore/domain/repositories/lore_repository.dart';

part 'lore_state.dart';
part 'lore_cubit.freezed.dart';

@injectable
class LoreCubit extends Cubit<LoreState> {
  LoreCubit(this._repository) : super(const LoreState()) {
    unawaited(loadLore());
  }

  final LoreRepository _repository;

  Future<void> loadLore() async {
    final realItems = state.items;
    final mockedItems = LoreMockGenerator.generate(10);

    emit(state.copyWith(isLoading: true, items: mockedItems));

    final result = await _repository.getPlates();

    switch (result) {
      case Success(value: final value):
        emit(
          state.copyWith(
            isLoading: false,
            items: value,
            error: null,
          ),
        );

      case Error(error: final error):
        emit(
          state.copyWith(
            isLoading: false,
            items: realItems,
            error: error.toString(),
          ),
        );
    }
  }
}
