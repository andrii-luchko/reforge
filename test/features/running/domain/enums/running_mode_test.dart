import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';

void main() {
  test('running modes round-trip through their persisted values', () {
    for (final mode in RunningMode.values) {
      expect(RunningMode.fromDb(mode.dbValue), mode);
    }
  });

  test('legacy pedometer DB value maps to treadmill', () {
    expect(RunningMode.fromDb('pedometer'), RunningMode.treadmill);
    expect(RunningMode.fromDb('treadmill'), RunningMode.treadmill);
    expect(RunningMode.fromDb(null), isNull);
    expect(RunningMode.fromDb('unknown'), isNull);
  });
}
