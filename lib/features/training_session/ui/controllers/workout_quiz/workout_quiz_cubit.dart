import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/training_session/domain/enums/body_feel.dart';
import 'package:reforge/features/training_session/domain/enums/energized_level.dart';
import 'package:reforge/features/training_session/domain/enums/hydrated_level.dart';
import 'package:reforge/features/training_session/domain/enums/sleep_quality.dart';
import 'package:reforge/features/training_session/domain/enums/stress_level.dart';
import 'package:reforge/features/training_session/domain/enums/work_out_quiz_steps.dart';

part 'workout_quiz_cubit.freezed.dart';
part 'workout_quiz_state.dart';

@injectable
class WorkoutQuizCubit extends Cubit<WorkoutQuizState> {
  WorkoutQuizCubit() : super(const WorkoutQuizState());

  bool get isStepValid {
    final currentStep = WorkOutQuizSteps.values[state.currentStep];

    return switch (currentStep) {
      WorkOutQuizSteps.sleepQualityStep => state.sleepQuality != null,
      WorkOutQuizSteps.energizedLevelStep => state.energizedLevel != null,
      WorkOutQuizSteps.stressLevelStep => state.stressLevel != null,
      WorkOutQuizSteps.bodyFellStep => state.bodyFeel != null,
      WorkOutQuizSteps.hydratedLevelStep => state.hydratedLevel != null,
      WorkOutQuizSteps.hasEatenRecentlyStep => true,
      WorkOutQuizSteps.isMorningSessionStep => true,
    };
  }

  void onStepChanged(int index) {
    emit(state.copyWith(currentStep: index));
  }

  void setSleepQuality(SleepQuality value) {
    emit(state.copyWith(sleepQuality: value));
  }

  void setEnergizedLevel(EnergizedLevel value) {
    emit(state.copyWith(energizedLevel: value));
  }

  void setStressLevel(StressLevel value) {
    emit(state.copyWith(stressLevel: value));
  }

  void setBodyFeel(BodyFeel value) {
    emit(state.copyWith(bodyFeel: value));
  }

  void setHydratedLevel(HydratedLevel value) {
    emit(state.copyWith(hydratedLevel: value));
  }

  // ignore: avoid_positional_boolean_parameters
  void setHasEatenRecently(bool value) {
    emit(state.copyWith(hasEatenRecently: value));
  }

  // ignore: avoid_positional_boolean_parameters
  void setIsMorningSession(bool value) {
    emit(state.copyWith(isMorningSession: value));
  }

  bool get isFormComplete {
    return state.sleepQuality != null &&
        state.energizedLevel != null &&
        state.stressLevel != null &&
        state.bodyFeel != null &&
        state.hydratedLevel != null;
  }

  Future<void> onSubmit() async {
    if (!isFormComplete) {
      return;
    }

    emit(state.copyWith(isLoading: true, apiError: null));

    try {
      await Future.delayed(const Duration(seconds: 1));

      emit(
        state.copyWith(
          isLoading: false,
          isSubmitted: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          apiError: e.toString(),
        ),
      );
    }
  }
}
