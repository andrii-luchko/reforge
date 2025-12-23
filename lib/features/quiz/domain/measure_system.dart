import 'package:reforge/generated/i18n/translations.g.dart';

enum MeasurementSystem { metric, imperial }

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
