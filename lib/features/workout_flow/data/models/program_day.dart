import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_flow/data/models/program_exercise.dart';

part 'program_day.freezed.dart';
part 'program_day.g.dart';

@Freezed(
  copyWith: false,
  fromJson: true,
  toStringOverride: true,
)
sealed class ProgramDay with _$ProgramDay {
  const ProgramDay._();

  const factory ProgramDay({
    required int id,
    required String name,
    required int dayNumber,

    required List<ProgramExercise> exercises,
  }) = _ProgramDay;

  factory ProgramDay.fromJson(Map<String, dynamic> json) => _$ProgramDayFromJson(json);

  List<ProgramExercise> get sortedExercises {
    final sortedList = [...exercises]..sort((a, b) => a.order.compareTo(b.order));
    return sortedList;
  }
}
