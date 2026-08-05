import 'package:reforge/features/running/domain/services/tracking_engine.dart';

/// A tracking engine whose current speed is supplied by the user.
///
/// This capability is intentionally separate from [TrackingEngine] because
/// sensor-driven engines such as GPS cannot accept an external speed.
abstract interface class AdjustableSpeedTrackingEngine implements TrackingEngine {
  /// Applies a canonical speed in kilometers per hour.
  void setSpeedKmH(double speedKmH);
}
