import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/data/services/pedometer_metrics_accumulator.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// Pedometer-based [TrackingEngine] for treadmill workouts.
///
/// Registered as the default [TrackingEngine] in the DI container.
class PedometerTrackingEngine implements TrackingEngine {
  /// Ticker interval — we derive duration from a wall-clock stopwatch rather
  /// than relying on the pedometer timestamp, which varies per device.
  static const Duration _tickInterval = RunningConstants.engineTickInterval;

  static const int _stallTimeoutMs = 2500;

  // ── State ──────────────────────────────────────────────────────────────────

  final _controller = StreamController<RunningMetrics>.broadcast();

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;
  StreamSubscription<Position>? _iosKeepAliveSub;
  Timer? _tickTimer;

  bool _isPaused = false;
  final _metricsAccumulator = PedometerMetricsAccumulator();

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (_tickTimer != null) return; // Already tracking — ignore.

    _isPaused = false;

    _metricsAccumulator.start(initialOffset: initialOffset);

    logger.d('PedometerTrackingEngine: starting');

    // Subscribe to the device step counter.
    _stepSub = Pedometer.stepCountStream.listen(
      _onStep,
      onError: (Object e, StackTrace st) {
        // PlatformException code 3 = "Step Count is not available" — the
        // hardware sensor is physically absent (simulator, some tablets).
        // This is FATAL for this session: no point retrying.
        if (e is PlatformException && e.code == '3') {
          logger.e('PedometerTrackingEngine: sensor unavailable (code 3). Stopping.', e, st);
          unawaited(stop());
          _controller.addError(
            SensorUnavailableException('pedometer', cause: e),
            st,
          );
          return;
        }
        // All other errors are potentially transient — log and keep listening.
        logger.e('PedometerTrackingEngine: step stream error (recoverable)', e, st);
        _controller.addError(e, st);
      },
      // CRITICAL: cancelOnError:false prevents Dart from silently closing the
      // subscription on the first error. We handle cancellation explicitly above.
      cancelOnError: false,
    );

    // Subscribe to pedestrian status to instantly snap speed to 0 when stopped
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (status) {
        if (status.status == 'stopped') {
          _metricsAccumulator.markStopped();
        }
      },
      onError: (_) {
        // Ignored. Fallback to EMA decay if stream is unavailable.
      },
      cancelOnError: false,
    );

    // Wall-clock tick to increment duration and emit metrics every second.
    _tickTimer = Timer.periodic(_tickInterval, (_) => _onTick());

    if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
      _iosKeepAliveSub =
          Geolocator.getPositionStream(
            locationSettings: AppleSettings(
              accuracy: LocationAccuracy.lowest,
              distanceFilter: 100,
              activityType: ActivityType.fitness,
              showBackgroundLocationIndicator: true,
            ),
          ).listen(
            (_) {},
            onError: (Object e, StackTrace st) {
              logger.w('PedometerTrackingEngine: iOS location keep-alive unavailable: $e');
            },
            cancelOnError: false,
          );
    }
  }

  @override
  void pause() {
    _isPaused = true;
    _metricsAccumulator.pause();
    logger.d('PedometerTrackingEngine: paused');
  }

  @override
  void resume() {
    _isPaused = false;
    _metricsAccumulator.resume();
    logger.d('PedometerTrackingEngine: resumed');
  }

  @override
  Future<void> stop() async {
    _tickTimer?.cancel();
    _tickTimer = null;

    final stepCancellation = _stepSub?.cancel();
    final statusCancellation = _statusSub?.cancel();
    final iosKeepAliveCancellation = _iosKeepAliveSub?.cancel();

    _stepSub = null;
    _statusSub = null;
    _iosKeepAliveSub = null;

    await Future.wait([
      ?stepCancellation,
      ?statusCancellation,
      ?iosKeepAliveCancellation,
    ]);

    _isPaused = false;
    logger.d('PedometerTrackingEngine: stopped');
  }

  @override
  void reset() {
    _metricsAccumulator.start();
    logger.d('PedometerTrackingEngine: metrics reset');
  }

  // ── Private ────────────────────────────────────────────────────────────────

  void _onStep(StepCount event) {
    _metricsAccumulator.recordRawStep(
      rawStepCount: event.steps,
      timestampMs: event.timeStamp.millisecondsSinceEpoch,
    );
  }

  void _onTick() {
    if (_isPaused) return;

    _metricsAccumulator.tick(
      nowMs: DateTime.now().millisecondsSinceEpoch,
      stallTimeoutMs: _stallTimeoutMs,
    );
    _controller.add(_metricsAccumulator.metrics);
  }

  /// Dispose when the singleton is torn down (e.g. during testing).
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
