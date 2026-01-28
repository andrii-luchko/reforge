import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/training_session/data/enums/workout_session_status.dart';

part 'workout_session.freezed.dart';
part 'workout_session.g.dart';

@freezed
sealed class WorkoutSession with _$WorkoutSession {
  const factory WorkoutSession({
    required int id,
    required int userId,
    required int workoutProgramDayId,
    required int exerciseTypeId,
    required int duration,
    required WorkoutSessionStatus status,
    required int totalXpEarned,
  }) = _WorkoutSession;

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => _$WorkoutSessionFromJson(json);
}
