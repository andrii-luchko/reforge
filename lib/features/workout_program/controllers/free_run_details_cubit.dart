import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/helpers/result.dart';
import 'package:reforge/features/workout_program/domain/entities/exercise_details_entity.dart';
import 'package:reforge/features/workout_program/domain/repositories/exercise_catalog_repository.dart';
import 'package:reforge/features/workout_session/domain/entities/workout_execution_plan.dart';

class FreeRunDetailsState {
  const FreeRunDetailsState({
    this.exercise,
    this.isLoading = true,
    this.error,
  });

  final ExerciseDetailsEntity? exercise;
  final bool isLoading;
  final String? error;

  WorkoutExecutionPlan? get executionPlan {
    final details = exercise;
    if (details == null) return null;
    return WorkoutExecutionPlan.freeRun(
      details: details,
      executionKey: FreeRunDetailsCubit.executionKey,
    );
  }
}

@injectable
class FreeRunDetailsCubit extends Cubit<FreeRunDetailsState> {
  FreeRunDetailsCubit(this._repository) : super(const FreeRunDetailsState());

  static const executionKey = 'free-run:running';

  final ExerciseCatalogRepository _repository;

  Future<void> load() async {
    if (state.exercise != null) return;
    emit(const FreeRunDetailsState());

    final result = await _repository.getExercise(WorkoutExecutionPlan.freeRunExerciseId);
    switch (result) {
      case Success(value: final exercise):
        emit(FreeRunDetailsState(exercise: exercise, isLoading: false));
      case Failure(:final error):
        emit(FreeRunDetailsState(isLoading: false, error: error.toString()));
    }
  }

  Future<void> retry() async {
    emit(const FreeRunDetailsState());
    final result = await _repository.getExercise(WorkoutExecutionPlan.freeRunExerciseId);
    switch (result) {
      case Success(value: final exercise):
        emit(FreeRunDetailsState(exercise: exercise, isLoading: false));
      case Failure(:final error):
        emit(FreeRunDetailsState(isLoading: false, error: error.toString()));
    }
  }
}
