import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise_details.freezed.dart';
part 'exercise_details.g.dart';

@freezed
sealed class ExerciseDetails with _$ExerciseDetails {
  const factory ExerciseDetails({
    required int id,
    required String name,
    required String description,
    @Default({}) Map<String, String> instructionSteps,
    String? imageUrl,
    String? videoUrl,
  }) = _ExerciseDetails;

  factory ExerciseDetails.fromJson(Map<String, dynamic> json) => _$ExerciseDetailsFromJson(json);
}
