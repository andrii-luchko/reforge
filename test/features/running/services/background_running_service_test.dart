import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/services/background_running_service.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';

void main() {
  test('selects exactly one Android foreground type per running mode', () {
    expect(
      androidForegroundServiceTypesForMode(RunningMode.gps),
      [AndroidForegroundType.location],
    );
    expect(
      androidForegroundServiceTypesForMode(RunningMode.treadmill),
      [AndroidForegroundType.health],
    );
    expect(
      androidForegroundServiceTypesForMode(RunningMode.pedometer),
      [AndroidForegroundType.health],
    );
  });
}
