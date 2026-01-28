import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_summary.freezed.dart';
part 'workout_summary.g.dart';

@freezed
sealed class WorkoutSessionSummary with _$WorkoutSessionSummary {
  const factory WorkoutSessionSummary({
    @JsonKey(name: 'id') required int workoutSessionId,
    @JsonKey(name: 'duration') required int duration,
    @JsonKey(name: 'totalXpEarned') required int totalXpEarned,
  }) = _WorkoutSessionSummary;

  factory WorkoutSessionSummary.fromJson(Map<String, dynamic> json) => _$WorkoutSessionSummaryFromJson(json);
}
