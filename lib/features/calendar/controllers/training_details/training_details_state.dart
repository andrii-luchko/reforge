part of 'training_details_cubit.dart';

@freezed
sealed class TrainingDetailsState with _$TrainingDetailsState {
  const factory TrainingDetailsState.initial() = _Initial;
  const factory TrainingDetailsState.loading() = _Loading;
  const factory TrainingDetailsState.loaded(TrainingDetailsEntity data) = _Loaded;
  const factory TrainingDetailsState.error(String message) = _Error;
}
