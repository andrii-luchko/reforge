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
  String title(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return '${t.measure_system.metric} (${t.measure_system.weight.metric_symbol})';
      case MeasurementSystem.imperial:
        return '${t.measure_system.imperial} (${t.measure_system.weight.imperial_symbol})';
    }
  }

  String weightName(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return t.measure_system.weight.metric_name;
      case MeasurementSystem.imperial:
        return t.measure_system.weight.imperial_name;
    }
  }

  String weightSymbol(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return t.measure_system.weight.metric_symbol;
      case MeasurementSystem.imperial:
        return t.measure_system.weight.imperial_symbol;
    }
  }

  String distanceSymbol(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return t.measure_system.distance.metric_symbol;
      case MeasurementSystem.imperial:
        return t.measure_system.distance.imperial_symbol;
    }
  }

  String distanceTitle(Translations t) {
    switch (this) {
      case MeasurementSystem.metric:
        return t.measure_system.distance.metric_name;
      case MeasurementSystem.imperial:
        return t.measure_system.distance.imperial_name;
    }
  }
}
