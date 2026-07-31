import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/utils/helpers/meta_data.dart';
import 'package:reforge/features/exercise_session/data/models/swap_exercise_search_item_dto.dart';

part 'swap_exercise_search_response.freezed.dart';
part 'swap_exercise_search_response.g.dart';

@freezed
sealed class SwapExerciseSearchResponse with _$SwapExerciseSearchResponse {
  const factory SwapExerciseSearchResponse({
    required List<SwapExerciseSearchItemDTO> data,
    required MetaData meta,
    required String status,
  }) = _SwapExerciseSearchResponse;

  factory SwapExerciseSearchResponse.fromJson(Map<String, dynamic> json) => _$SwapExerciseSearchResponseFromJson(json);
}
