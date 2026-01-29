import 'package:freezed_annotation/freezed_annotation.dart';

@JsonEnum()
enum WorkoutSessionStatus {
  active,
  canceled,
  completed,
}
