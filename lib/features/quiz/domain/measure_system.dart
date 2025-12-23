enum MeasurementSystem { metric, imperial }

extension MeasurementSystemExtension on MeasurementSystem {
  String get weight {
    switch (this) {
      case MeasurementSystem.metric:
        return 'kg';
      case MeasurementSystem.imperial:
        return 'lb';
    }
  }
}
