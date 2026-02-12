import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/calendar/data/repository/calendar_repository.dart';
import 'package:reforge/features/calendar/domain/entity/training_details_entity.dart';

part 'training_details_state.dart';
part 'training_details_cubit.freezed.dart';

@injectable
class TrainingDetailsCubit extends Cubit<TrainingDetailsState> {
  TrainingDetailsCubit(this._repository, @factoryParam this._sessionId) : super(const TrainingDetailsState.initial()) {
    unawaited(loadWorkoutDetails());
  }

  final CalendarRepository _repository;
  final int _sessionId;

  Future<void> loadWorkoutDetails({bool forceRefresh = false}) async {
    emit(const TrainingDetailsState.loading());

    final result = await _repository.getWorkoutDetails(_sessionId, forceRefresh: forceRefresh);

    switch (result) {
      case Success(value: final data):
        emit(TrainingDetailsState.loaded(data));
      case ErrorR(error: final error):
        emit(TrainingDetailsState.error(error.toString()));
    }
  }

  Future<void> refresh() => loadWorkoutDetails(forceRefresh: true);
}
