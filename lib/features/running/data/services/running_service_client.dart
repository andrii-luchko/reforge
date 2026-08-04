import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/data/services/running_service_protocol.dart';
import 'package:reforge/features/running/domain/entities/lap_limit.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_event.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/enums/running_mode.dart';
import 'package:reforge/features/running/domain/exceptions/running_service_exceptions.dart';
import 'package:reforge/features/workout_program/data/enums/segment_activity.dart';

/// Fire-and-forget UI-isolate client for the running background worker.
///
/// Commands are never gated by acknowledgements from the worker. The iOS
/// plugin reliably delivers commands but may drop reverse-channel lifecycle
/// events such as `service_ready`.
@lazySingleton
class RunningServiceClient {
  RunningServiceClient() : _service = FlutterBackgroundService();

  @visibleForTesting
  RunningServiceClient.withService(this._service);

  final FlutterBackgroundService _service;

  final _metricsController = StreamController<RunningMetrics>.broadcast();
  final _eventsController = StreamController<RunningEvent>.broadcast();

  bool _isListening = false;
  bool _hasLoggedFirstMetric = false;
  Future<void>? _warmUpFuture;
  RunningMode? _currentMode;

  Stream<RunningMetrics> get metricsStream => _metricsController.stream;
  Stream<RunningEvent> get eventsStream => _eventsController.stream;
  RunningMode? get currentMode => _currentMode;

  /// Installs all reverse-channel listeners before any worker command is sent.
  Future<void> initialize() async {
    if (_isListening) return;
    _isListening = true;

    _service.on('metrics').listen((event) {
      if (event == null) return;
      try {
        if (!_hasLoggedFirstMetric) {
          _hasLoggedFirstMetric = true;
          _log('first_metric_received');
        }

        final latitude = RunningServiceProtocol.optionalDouble(event, 'lat');
        final longitude = RunningServiceProtocol.optionalDouble(event, 'lng');
        if ((latitude == null) != (longitude == null)) {
          throw ServiceProtocolException(
            key: 'lat/lng',
            expectedType: 'both coordinates or neither',
            actualValue: '${event['lat']}/${event['lng']}',
          );
        }

        final activityName = RunningServiceProtocol.optionalString(event, 'activityType');
        _metricsController.add(
          RunningMetrics(
            distanceMeters: RunningServiceProtocol.requiredDouble(event, 'distanceMeters'),
            durationSeconds: RunningServiceProtocol.requiredInt(event, 'durationSeconds'),
            avgSpeedKmH: RunningServiceProtocol.requiredDouble(event, 'avgSpeedKmH'),
            currentSpeedKmH: RunningServiceProtocol.requiredDouble(event, 'currentSpeedKmH'),
            avgPaceMinKm: RunningServiceProtocol.requiredDouble(event, 'avgPaceMinKm'),
            currentPaceMinKm: RunningServiceProtocol.requiredDouble(event, 'currentPaceMinKm'),
            stepCount: RunningServiceProtocol.requiredInt(event, 'stepCount'),
            currentSegmentIndex: RunningServiceProtocol.optionalInt(event, 'currentSegmentIndex') ?? 0,
            segmentId: RunningServiceProtocol.optionalInt(event, 'segmentId'),
            activityType: SegmentActivity.values.firstWhere(
              (activity) => activity.name == activityName,
              orElse: () => SegmentActivity.run,
            ),
            currentLocation: latitude == null
                ? null
                : RouteCoordinate(
                    latitude: latitude,
                    longitude: longitude!,
                    heading: RunningServiceProtocol.optionalDouble(event, 'heading') ?? 0,
                  ),
          ),
        );
      } on Object catch (error, stackTrace) {
        _reportProtocolError('metrics', error, stackTrace, _metricsController);
      }
    });

    _service.on('events').listen((event) {
      if (event == null) return;
      try {
        final type = RunningServiceProtocol.requiredString(event, 'type');
        if (type == 'LapCompletedEvent') {
          _eventsController.add(
            LapCompletedEvent(
              segmentIndex: RunningServiceProtocol.requiredInt(event, 'segmentIndex'),
              segmentId: RunningServiceProtocol.optionalInt(event, 'segmentId'),
            ),
          );
        } else if (type == 'PlannedWorkoutCompletedEvent') {
          _eventsController.add(const PlannedWorkoutCompletedEvent());
        }
      } on Object catch (error, stackTrace) {
        _reportProtocolError('events', error, stackTrace, _eventsController);
      }
    });

    _service.on('sensor_error').listen((event) {
      _forwardRemoteError(
        event,
        fallbackCode: 'sensor_stream_error',
        fallbackFatal: false,
      );
    });
    _service.on('fatal_error').listen((event) {
      _forwardRemoteError(
        event,
        fallbackCode: 'background_service_failed',
        fallbackFatal: true,
      );
    });

    // Diagnostic only. Missing this event must never delay a command.
    _service.on('service_ready').listen((event) {
      try {
        final elapsedMs = event == null ? null : RunningServiceProtocol.optionalInt(event, 'bootstrapElapsedMs');
        _log('service_ready_observed workerElapsedMs=$elapsedMs');
      } on Object catch (error, stackTrace) {
        logger.e('RunningServiceClient: invalid service_ready payload', error, stackTrace);
      }
    });
  }

  Future<bool> get isRunning => _service.isRunning();

  /// Starts an idle worker during the countdown without starting sensors.
  ///
  /// Warm-up is best effort by design. A real failure is logged here and will
  /// be retried by [startSession], where it can be surfaced to the Cubit.
  Future<void> warmUp() {
    final inFlight = _warmUpFuture;
    if (inFlight != null) return inFlight;

    final future = _warmUpInternal();
    _warmUpFuture = future;
    unawaited(
      future.whenComplete(() {
        if (identical(_warmUpFuture, future)) _warmUpFuture = null;
      }),
    );
    return future;
  }

  Future<void> _warmUpInternal() async {
    try {
      await initialize();
      if (await _service.isRunning()) {
        _log('warm_up_worker_already_running');
        return;
      }

      _log('warm_up_start_service');
      final started = await _service.startService();
      _log('warm_up_start_service_result=$started');
    } on Object catch (error, stackTrace) {
      logger.e('RunningServiceClient: worker warm-up failed', error, stackTrace);
    }
  }

  /// Dispatches `start_session` without waiting for a reverse-channel ACK.
  Future<void> startSession({
    required RunningMode mode,
    required List<LapLimit> limits,
    required int sessionId,
    required int programExerciseId,
    bool startPaused = false,
    bool restoreCompletedPlan = false,
  }) async {
    await initialize();

    if (!await _service.isRunning()) {
      _log('start_session_cold_start');
      final started = await _service.startService();
      if (!started) {
        throw const RunningServiceException(
          code: 'background_service_start_failed',
          message: 'The running service could not be started.',
          isFatal: true,
        );
      }
    }

    _currentMode = mode;
    _hasLoggedFirstMetric = false;
    _service.invoke('start_session', {
      'sessionId': sessionId,
      'programExerciseId': programExerciseId,
      'mode': mode.name,
      'startPaused': startPaused,
      'restoreCompletedPlan': restoreCompletedPlan,
      'limits': limits
          .map(
            (limit) => {
              'metric': limit.metric.name,
              'limitValue': limit.limitValue,
              'segmentId': limit.segmentId,
              'activityType': limit.activityType.name,
            },
          )
          .toList(),
    });
    _log(
      'start_session_sent mode=${mode.name} startPaused=$startPaused '
      'restoreCompletedPlan=$restoreCompletedPlan',
    );
  }

  void pauseSession() => _invokeControl('pause_session');
  void resumeSession() => _invokeControl('resume_session');
  void suspendSessionForSummary() => _invokeControl('suspend_session');
  void forceNextLap() => _invokeControl('force_next_lap');

  void endSession() {
    _currentMode = null;
    _invokeControl('stop_session');
  }

  void _invokeControl(String method) {
    _service.invoke(method, const {});
    _log('${method}_sent');
  }

  void _reportProtocolError<T>(
    String eventName,
    Object error,
    StackTrace stackTrace,
    StreamController<T> controller,
  ) {
    logger.e('RunningServiceClient: invalid $eventName payload', error, stackTrace);
    controller.addError(
      RunningServiceException(
        code: 'service_protocol_error',
        message: error.toString(),
        isFatal: true,
      ),
      stackTrace,
    );
  }

  void _forwardRemoteError(
    Map<String, dynamic>? event, {
    required String fallbackCode,
    required bool fallbackFatal,
  }) {
    if (event == null) return;
    try {
      _metricsController.addError(
        RunningServiceException(
          code: RunningServiceProtocol.optionalString(event, 'code') ?? fallbackCode,
          message: RunningServiceProtocol.requiredString(event, 'message'),
          isFatal: RunningServiceProtocol.optionalBool(event, 'isFatal', fallback: fallbackFatal),
        ),
      );
    } on Object catch (error, stackTrace) {
      _reportProtocolError('error', error, stackTrace, _metricsController);
    }
  }

  void _log(String stage) {
    logger.d('[RunningServiceClient][${DateTime.now().toIso8601String()}] $stage');
  }
}
