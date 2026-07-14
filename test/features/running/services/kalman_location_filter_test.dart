import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/services/kalman_location_filter.dart';

void main() {
  group('KalmanLocationFilter', () {
    test('reports initialization without treating the anchor as movement', () {
      final filter = KalmanLocationFilter();

      final result = filter.process(
        lat: 50,
        lng: 30,
        accuracy: 5,
        timestampMs: 1000,
      );

      expect(result, KalmanUpdateResult.initialized);
      expect(filter.latitude, 50);
      expect(filter.longitude, 30);
    });

    test('accepts a plausible new location', () {
      final filter = KalmanLocationFilter()..process(lat: 50, lng: 30, accuracy: 5, timestampMs: 1000);

      final result = filter.process(
        lat: 50.00001,
        lng: 30,
        accuracy: 5,
        timestampMs: 2000,
      );

      expect(result, KalmanUpdateResult.accepted);
    });

    test('reports stale timestamps without advancing the filter', () {
      final filter = KalmanLocationFilter()..process(lat: 50, lng: 30, accuracy: 5, timestampMs: 1000);

      final result = filter.process(
        lat: 50.00001,
        lng: 30,
        accuracy: 5,
        timestampMs: 1000,
      );

      expect(result, KalmanUpdateResult.ignoredStale);
      expect(filter.latitude, 50);
    });

    test('reports a GPS outlier so callers can avoid adding its distance', () {
      final filter = KalmanLocationFilter()
        ..process(lat: 50, lng: 30, accuracy: 5, timestampMs: 1000)
        ..process(lat: 50.00001, lng: 30, accuracy: 5, timestampMs: 2000);

      final result = filter.process(
        lat: 51,
        lng: 31,
        accuracy: 5,
        timestampMs: 3000,
      );

      expect(result, KalmanUpdateResult.rejectedOutlier);
    });
  });
}
