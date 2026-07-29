part of 'guide_cubit.dart';

@freezed
sealed class GuideState with _$GuideState {
  const factory GuideState.initial() = GuideInitial;

  const factory GuideState.checking() = GuideChecking;

  const factory GuideState.running({
    required int currentStep,
    required int totalSteps,
  }) = GuideRunning;

  const factory GuideState.completed() = GuideCompleted;
}
