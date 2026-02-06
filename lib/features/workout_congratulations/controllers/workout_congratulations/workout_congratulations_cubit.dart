// workout_congratulations_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/workout_common/domain/entities/workout_summary_entity.dart';

part 'workout_congratulations_state.dart';
part 'workout_congratulations_cubit.freezed.dart';

@injectable
class WorkoutCongratulationsCubit extends Cubit<WorkoutCongratulationsState> {
  WorkoutCongratulationsCubit(@factoryParam WorkoutSessionSummaryEntity? result)
    : super(
        WorkoutCongratulationsState(
          workoutResult: result,

          navigationTarget: result == null ? const WorkoutNavigationTarget.home() : null,
        ),
      );

  void init() {
    if (state.workoutResult == null) return;
  }

  void onNextPressed({int? currentMilestoneIndex}) {
    final result = state.workoutResult;
    if (result == null) {
      emit(state.copyWith(navigationTarget: const WorkoutNavigationTarget.home()));
      return;
    }

    final milestones = result.earnedMilestones;

    if (currentMilestoneIndex == null) {
      emit(state.copyWith(navigationTarget: const WorkoutNavigationTarget.home()));
      return;
    }

    final nextIndex = currentMilestoneIndex + 1;

    if (nextIndex < milestones.length) {
      emit(state.copyWith(navigationTarget: WorkoutNavigationTarget.achievement(nextIndex)));
    } else {
      emit(state.copyWith(navigationTarget: const WorkoutNavigationTarget.summary()));
    }
  }

  void onNavigationConsumed() {
    emit(state.copyWith(navigationTarget: null));
  }
}
