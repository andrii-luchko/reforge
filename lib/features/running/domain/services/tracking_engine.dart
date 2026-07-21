import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';

/// Abstract interface for a low-level tracking engine.
///
/// Implementations (e.g., Pedometer, GPS) are solely responsible for generating
/// raw metric streams (distance, time, steps, coordinates). They do not handle
/// business logic like laps, segments, or database synchronization.
abstract interface class TrackingEngine {
  /// Stream of live [RunningMetrics].
  ///
  /// Emits a new value every time the underlying sensor produces data.
  /// A recoverable sensor problem is emitted as a [SensorStreamException] and
  /// does not stop the stream. A [TrackingEngineFailureException] is terminal:
  /// the engine has stopped and will not emit more metrics until [start] is
  /// called for a new session.
  Stream<RunningMetrics> get metricsStream;

  /// Starts the engine.
  ///
  /// If [initialOffset] is provided, the engine should resume accumulating metrics
  /// from the given baseline (e.g., after an app restart).
  ///
  /// Throws [TrackingEngineFailureException] when a required sensor, service,
  /// or permission is unavailable before tracking starts.
  Future<void> start({RunningMetrics? initialOffset});

  /// Pauses metric emission without releasing sensors.
  void pause();

  /// Resumes metric emission.
  void resume();

  /// Stops the engine and waits until all sensor resources are released.
  Future<void> stop();

  /// Resets accumulated metrics (distance, steps, duration) to zero.
  void reset();
}
