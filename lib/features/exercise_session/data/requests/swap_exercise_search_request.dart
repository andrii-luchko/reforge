import 'package:freezed_annotation/freezed_annotation.dart';

part 'swap_exercise_search_request.freezed.dart';
part 'swap_exercise_search_request.g.dart';

@freezed
sealed class SwapExerciseSearchRequest with _$SwapExerciseSearchRequest {
  @JsonSerializable(includeIfNull: false)
  const factory SwapExerciseSearchRequest({
    String? search,
    int? factionId,
    @Default(1) int page,
    @Default(20) int limit,
  }) = _SwapExerciseSearchRequest;

  factory SwapExerciseSearchRequest.fromJson(Map<String, dynamic> json) => _$SwapExerciseSearchRequestFromJson(json);
}
