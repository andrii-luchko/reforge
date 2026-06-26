import 'package:reforge/core/run_tracker/domain/enums/tracking_mode.dart';

/// The "Remote Control" for the beast in the background
abstract class BackgroundServiceController {
  /// Checks permissions, boots the isolate, and starts tracking
  Future<void> startTracking({required TrackingMode mode, required int sessionId});

  /// Pauses the hardware sensors temporarily
  Future<void> pauseTracking();

  /// Resumes hardware sensors
  Future<void> resumeTracking();

  /// Kills the background service and finalizes the session
  Future<void> stopTracking();
}
