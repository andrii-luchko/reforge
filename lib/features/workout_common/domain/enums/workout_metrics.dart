import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/app/utils/extensions/string_extensions.dart';
import 'package:reforge/features/quiz/domain/enums/measure_system.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum WorkoutMetric {
  @JsonValue('weightKg')
  weight,
  @JsonValue('reps')
  reps,
  @JsonValue('durationSec')
  time,
  @JsonValue('distanceM')
  distance,
  @JsonValue('speedKmH')
  pace,
  @JsonValue('angleDeg')
  degrees,
}

extension WorkoutMetricsX on WorkoutMetric {
  String title(Translations t, MeasurementSystem? system) {
    final name = switch (this) {
      WorkoutMetric.weight => t.metrics.weight,
      WorkoutMetric.reps => t.metrics.reps,
      WorkoutMetric.time => t.metrics.time,
      WorkoutMetric.distance => t.metrics.distance,
      WorkoutMetric.pace => t.metrics.pace,
      WorkoutMetric.degrees => t.metrics.degrees,
    };

    if (system == null) return name;

    String? unit;

    switch (this) {
      case WorkoutMetric.weight:
        unit = system == MeasurementSystem.imperial
            ? t.measure_system.weight.imperial_symbol.toCapitalized()
            : t.measure_system.weight.metric_symbol.toCapitalized();

      case WorkoutMetric.distance:
        unit = system == MeasurementSystem.imperial
            ? t.measure_system.distance.imperial_symbol.toCapitalized()
            : t.measure_system.distance.metric_symbol.toCapitalized();

      case WorkoutMetric.pace:
      case WorkoutMetric.degrees:
      case WorkoutMetric.time:
      case WorkoutMetric.reps:
    }

    return unit ?? name;
  }
}
