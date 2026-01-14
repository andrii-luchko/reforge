import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:reforge/generated/i18n/translations.g.dart';

@JsonEnum()
enum MeasurementSystem {
  @JsonValue('kg')
  metric,

  @JsonValue('lb')
  imperial,
}

extension MeasurementSystemExtension on MeasurementSystem {
  String weight(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return t.quiz.steps.measurement_system.metric;
      case MeasurementSystem.imperial:
        return t.quiz.steps.measurement_system.imperial;
    }
  }
}
