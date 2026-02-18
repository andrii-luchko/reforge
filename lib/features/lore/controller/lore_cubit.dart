import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/core/analytics/domain/analytics_events.dart';
import 'package:reforge/core/analytics/domain/analytics_service.dart';
import 'package:reforge/features/lore/domain/entity/plates_entity.dart';
import 'package:reforge/features/lore/domain/repositories/lore_repository.dart';

part 'lore_state.dart';
part 'lore_cubit.freezed.dart';

@injectable
class LoreCubit extends Cubit<LoreState> {
  LoreCubit(this._repository, this._analytics) : super(const LoreState()) {
    unawaited(_analytics.logEvent(AnalyticsEvents.loreView));
    unawaited(loadLore());
  }

  final LoreRepository _repository;
  final AnalyticsService _analytics;

  int _page = 1;

  Future<void> loadLore() async {
    final realItems = state.items;

    emit(state.copyWith(isLoading: true, error: null));
    _page = 1;

    final result = await _repository.getPlates(page: _page);

    if (isClosed) return;

    switch (result) {
      case Success(value: final data):
        emit(
          state.copyWith(
            isLoading: false,
            items: data.items,
            totalCount: data.total,
            hasMore: data.hasMore,
            error: null,
          ),
        );

      case ErrorR(error: final error):
        emit(
          state.copyWith(
            isLoading: false,
            items: realItems,
            error: error.toString(),
          ),
        );
    }
  }

  Future<void> loadMore() async {
    final currentState = state;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));
    _page++;

    final result = await _repository.getPlates(page: _page);

    if (isClosed) return;

    final newState = state;
    switch (result) {
      case Success(value: final data):
        final merged = [...currentState.items, ...data.items];
        emit(
          newState.copyWith(
            items: merged,
            totalCount: data.total,
            hasMore: data.hasMore,
            isLoadingMore: false,
          ),
        );

      case ErrorR(error: final error):
        _page--;
        emit(
          newState.copyWith(
            isLoadingMore: false,
            error: error.toString(),
          ),
        );
    }
  }

  void onRefresh() {
    unawaited(_analytics.logEvent(AnalyticsEvents.loreRefresh));
  }

  Future<void> loadPlateDetail(int id) async {
    final existingItem = state.items.where((e) => e.id == id).firstOrNull;
    if (existingItem == null) return;
    if (existingItem.loreBody != null) return;

    unawaited(_analytics.logEvent(AnalyticsEvents.lorePlateClick, {'plate_id': id}));
    emit(state.copyWith(loadingDetailId: id));

    final result = await _repository.getPlateById(id);

    if (isClosed) return;

    emit(state.copyWith(loadingDetailId: null));

    switch (result) {
      case Success(value: final detail):
        final updatedItems = state.items.map((item) {
          if (item.id == id) return detail;
          return item;
        }).toList();
        emit(state.copyWith(items: updatedItems));

      case ErrorR(error: final error):
        emit(state.copyWith(error: error.toString()));
    }
  }
}
