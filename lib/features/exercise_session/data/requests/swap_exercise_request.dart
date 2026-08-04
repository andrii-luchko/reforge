import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_exercise_request.freezed.dart';
part 'swap_exercise_request.g.dart';

@freezed
sealed class SwapExerciseRequest with _$SwapExerciseRequest {
  const factory SwapExerciseRequest({
    required int swappedExerciseId,
  }) = _SwapExerciseRequest;

  factory SwapExerciseRequest.fromJson(Map<String, dynamic> json) => _$SwapExerciseRequestFromJson(json);
}
