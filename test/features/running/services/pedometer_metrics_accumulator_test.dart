import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/services/pedometer_metrics_accumulator.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';

void main() {
  group('PedometerMetricsAccumulator', () {
    test('does not add steps made while paused after resume', () {
      final accumulator = PedometerMetricsAccumulator()
        ..start()
        ..recordRawStep(rawStepCount: 1000, timestampMs: 0)
        ..recordRawStep(rawStepCount: 1005, timestampMs: 1000)
        ..pause()
        ..recordRawStep(rawStepCount: 1105, timestampMs: 2000)
        ..resume()
        ..recordRawStep(rawStepCount: 1106, timestampMs: 3000);

      expect(accumulator.metrics.stepCount, 6);
      expect(accumulator.metrics.distanceMeters, closeTo(4.68, 0.001));
    });

    test('drops the first resumed batch when no events arrived while paused', () {
      final accumulator = PedometerMetricsAccumulator()
        ..start()
        ..recordRawStep(rawStepCount: 1000, timestampMs: 0)
        ..recordRawStep(rawStepCount: 1005, timestampMs: 1000)
        ..pause()
        ..resume()
        ..recordRawStep(rawStepCount: 1105, timestampMs: 3000);

      expect(accumulator.metrics.stepCount, 5);
      expect(accumulator.metrics.distanceMeters, closeTo(3.9, 0.001));
    });

    test('keeps persisted metrics after the first raw sensor event', () {
      final accumulator = PedometerMetricsAccumulator()
        ..start(
          initialOffset: const RunningMetrics(
            distanceMeters: 100,
            durationSeconds: 60,
            avgSpeedKmH: 0,
            currentSpeedKmH: 0,
            avgPaceMinKm: 0,
            currentPaceMinKm: 0,
            stepCount: 120,
          ),
        )
        ..recordRawStep(rawStepCount: 5000, timestampMs: 0);

      expect(accumulator.metrics.stepCount, 120);
      expect(accumulator.metrics.distanceMeters, 100);
      expect(accumulator.metrics.durationSeconds, 60);
    });

    test('rebases safely when the system counter decreases', () {
      final accumulator = PedometerMetricsAccumulator()
        ..start()
        ..recordRawStep(rawStepCount: 100, timestampMs: 0)
        ..recordRawStep(rawStepCount: 110, timestampMs: 1000)
        ..recordRawStep(rawStepCount: 5, timestampMs: 2000)
        ..recordRawStep(rawStepCount: 6, timestampMs: 3000);

      expect(accumulator.metrics.stepCount, 11);
      expect(accumulator.metrics.distanceMeters, greaterThan(0));
      expect(accumulator.metrics.currentSpeedKmH.isFinite, isTrue);
    });

    test('keeps speed finite for delayed events with equal timestamps', () {
      final accumulator = PedometerMetricsAccumulator()
        ..start()
        ..recordRawStep(rawStepCount: 100, timestampMs: 1000)
        ..recordRawStep(rawStepCount: 110, timestampMs: 2000)
        ..recordRawStep(rawStepCount: 120, timestampMs: 2000);

      expect(accumulator.metrics.currentSpeedKmH.isFinite, isTrue);
      expect(accumulator.metrics.currentSpeedKmH, lessThanOrEqualTo(25));
    });
  });
}
