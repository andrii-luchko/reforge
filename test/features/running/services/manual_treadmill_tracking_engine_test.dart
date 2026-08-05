import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:reforge/features/running/data/services/manual_treadmill_tracking_engine.dart';
import 'package:reforge/features/running/data/services/treadmill_background_keep_alive.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

void main() {
  late FakeMonotonicClock clock;
  late StreamController<void> ticks;
  late FakeTreadmillBackgroundKeepAlive keepAlive;
  late ManualTreadmillTrackingEngine engine;

  setUp(() {
    clock = FakeMonotonicClock();
    ticks = StreamController<void>.broadcast(sync: true);
    keepAlive = FakeTreadmillBackgroundKeepAlive();
    engine = ManualTreadmillTrackingEngine(
      backgroundKeepAlive: keepAlive,
      tickStreamFactory: (_) => ticks.stream,
      nowMicroseconds: () => clock.microseconds,
    );
  });

  tearDown(() async {
    await engine.dispose();
    await ticks.close();
  });

  test('uses monotonic elapsed time for constant-speed distance', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);
    engine.setSpeedKmH(10);
    await engine.start();

    clock.advance(const Duration(seconds: 36));
    ticks.add(null);

    expect(metrics.last.distanceMeters, closeTo(100, 0.000001));
    expect(metrics.last.durationSeconds, 36);
    expect(metrics.last.currentSpeedKmH, 10);
    expect(metrics.last.avgSpeedKmH, closeTo(10, 0.000001));
    expect(metrics.last.currentPaceMinKm, closeTo(6, 0.000001));
    expect(metrics.last.avgPaceMinKm, closeTo(6, 0.000001));
    expect(metrics.last.stepCount, 0);

    await subscription.cancel();
  });

  test('closes the old interval before applying a new speed', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);
    engine.setSpeedKmH(6);
    await engine.start();

    clock.advance(const Duration(seconds: 30));
    engine.setSpeedKmH(10);
    clock.advance(const Duration(seconds: 20));
    ticks.add(null);

    expect(metrics.last.distanceMeters, closeTo(105.555555, 0.000001));
    expect(metrics.last.durationSeconds, 50);
    expect(metrics.last.currentSpeedKmH, 10);
    expect(metrics.last.avgSpeedKmH, closeTo(7.6, 0.000001));

    await subscription.cancel();
  });

  test('pause excludes wall time and accepts a speed for resume', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);
    engine.setSpeedKmH(10);
    await engine.start();

    clock.advance(const Duration(seconds: 10));
    engine.pause();
    final distanceAtPause = metrics.last.distanceMeters;

    clock.advance(const Duration(seconds: 30));
    ticks.add(null);
    engine.setSpeedKmH(12);

    expect(metrics.last.distanceMeters, distanceAtPause);
    expect(metrics.last.durationSeconds, 10);
    expect(metrics.last.currentSpeedKmH, 12);

    engine.resume();
    clock.advance(const Duration(seconds: 10));
    ticks.add(null);

    expect(metrics.last.distanceMeters, closeTo(61.111111, 0.000001));
    expect(metrics.last.durationSeconds, 20);

    await subscription.cancel();
  });

  test('reset starts a new lap while retaining configured speed', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);
    engine.setSpeedKmH(8);
    await engine.start();

    clock.advance(const Duration(seconds: 10));
    ticks.add(null);
    engine.reset();
    clock.advance(const Duration(seconds: 10));
    ticks.add(null);

    expect(metrics.last.distanceMeters, closeTo(22.222222, 0.000001));
    expect(metrics.last.durationSeconds, 10);
    expect(metrics.last.currentSpeedKmH, 8);
    expect(metrics.last.avgSpeedKmH, closeTo(8, 0.000001));

    await subscription.cancel();
  });

  test('restores distance, active time, and current speed from offset', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);

    await engine.start(
      initialOffset: const RunningMetrics(
        distanceMeters: 100,
        durationSeconds: 60,
        avgSpeedKmH: 6,
        currentSpeedKmH: 6,
        avgPaceMinKm: 10,
        currentPaceMinKm: 10,
        stepCount: 0,
      ),
    );
    clock.advance(const Duration(seconds: 60));
    ticks.add(null);

    expect(metrics.last.distanceMeters, closeTo(200, 0.000001));
    expect(metrics.last.durationSeconds, 120);
    expect(metrics.last.currentSpeedKmH, 6);
    expect(metrics.last.avgSpeedKmH, closeTo(6, 0.000001));

    await subscription.cancel();
  });

  test('requires a valid speed before start and rejects invalid updates', () async {
    await expectLater(engine.start(), throwsArgumentError);

    for (final invalidSpeed in <double>[
      0,
      -1,
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(() => engine.setSpeedKmH(invalidSpeed), throwsArgumentError);
    }

    engine.setSpeedKmH(5);
    await expectLater(engine.start(), completes);
  });

  test('stop closes and emits the final partial interval', () async {
    final metrics = <RunningMetrics>[];
    final subscription = engine.metricsStream.listen(metrics.add);
    engine.setSpeedKmH(3.6);
    await engine.start();

    clock.advance(const Duration(milliseconds: 1500));
    await engine.stop();

    expect(metrics.last.distanceMeters, closeTo(1.5, 0.000001));
    expect(metrics.last.avgSpeedKmH, closeTo(3.6, 0.000001));

    await subscription.cancel();
  });

  test('forwards a terminal iOS keep-alive failure once', () async {
    final terminalError = _firstError(engine.metricsStream);
    engine.setSpeedKmH(5);
    await engine.start();
    const failure = TrackingEngineFailureException(
      engine: TrackingEngineType.treadmill,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationPermissionDenied,
    );

    keepAlive.failuresController.add(failure);

    expect(await terminalError, same(failure));
    await Future<void>.delayed(Duration.zero);
    expect(keepAlive.stopCalls, 1);
  });

  test('does not start ticking after keep-alive fails during start', () async {
    const failure = TrackingEngineFailureException(
      engine: TrackingEngineType.treadmill,
      dependency: TrackingDependency.location,
      reason: TrackingEngineFailureReason.locationServiceDisabled,
    );
    keepAlive.failureDuringStart = failure;
    final terminalError = _firstError(engine.metricsStream);
    engine.setSpeedKmH(5);

    await engine.start();

    expect(await terminalError, same(failure));
    expect(ticks.hasListener, isFalse);
    expect(keepAlive.stopCalls, 1);
  });
}

Future<Object> _firstError(Stream<Object?> stream) {
  final completer = Completer<Object>();
  late StreamSubscription<Object?> subscription;
  subscription = stream.listen(
    (_) {},
    onError: (Object error) {
      if (!completer.isCompleted) completer.complete(error);
      unawaited(subscription.cancel());
    },
  );
  return completer.future;
}

class FakeMonotonicClock {
  int microseconds = 0;

  void advance(Duration duration) {
    microseconds += duration.inMicroseconds;
  }
}

class FakeTreadmillBackgroundKeepAlive implements TreadmillBackgroundKeepAlive {
  final failuresController = StreamController<TrackingEngineFailureException>.broadcast(sync: true);
  int startCalls = 0;
  int stopCalls = 0;
  TrackingEngineFailureException? failureDuringStart;

  @override
  Stream<TrackingEngineFailureException> get failures => failuresController.stream;

  @override
  Future<void> start() async {
    startCalls++;
    final failure = failureDuringStart;
    if (failure != null) failuresController.add(failure);
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }

  @override
  Future<void> dispose() async {
    await failuresController.close();
  }
}
