import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/features/workout_common/domain/enums/workout_metrics.dart';

part 'lap_limit.freezed.dart';

/// Defines a target limit for a running lap/segment.
/// If tracking metrics reach this target, the tracker automatically laps.
@freezed
abstract class LapLimit with _$LapLimit {
  const factory LapLimit({
    required WorkoutMetric metric,
    required double limitValue, // seconds for time, meters for distance
  }) = _LapLimit;
}
