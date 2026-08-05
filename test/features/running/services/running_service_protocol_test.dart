import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/services/running_service_protocol.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

void main() {
  group('initialTreadmillSpeed', () {
    test('requires a positive canonical speed for treadmill mode', () {
      expect(
        RunningServiceProtocol.initialTreadmillSpeed(
          {'initialSpeedKmH': 8},
          RunningMode.treadmill,
        ),
        8,
      );
      expect(
        () => RunningServiceProtocol.initialTreadmillSpeed(
          const {},
          RunningMode.treadmill,
        ),
        throwsA(isA<ServiceProtocolException>()),
      );
      expect(
        () => RunningServiceProtocol.initialTreadmillSpeed(
          {'initialSpeedKmH': 0},
          RunningMode.treadmill,
        ),
        throwsArgumentError,
      );
    });

    test('requires the field to be absent for sensor-driven modes', () {
      expect(
        RunningServiceProtocol.initialTreadmillSpeed(
          const {},
          RunningMode.gps,
        ),
        isNull,
      );
      expect(
        () => RunningServiceProtocol.initialTreadmillSpeed(
          {'initialSpeedKmH': 8},
          RunningMode.gps,
        ),
        throwsA(isA<ServiceProtocolException>()),
      );
    });
  });
}
