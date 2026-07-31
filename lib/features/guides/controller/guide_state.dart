part of 'guide_cubit.dart';

@freezed
sealed class GuideState with _$GuideState {
  const factory GuideState.initial() = GuideInitial;

  const factory GuideState.checking({
    required GuideId guideId,
  }) = GuideChecking;

  const factory GuideState.running({
    required GuideId guideId,
    required int currentStep,
    required int totalSteps,
  }) = GuideRunning;

  const factory GuideState.completed({
    required GuideId guideId,
  }) = GuideCompleted;
}
