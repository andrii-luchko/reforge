import 'package:reforge/features/quiz/domain/enums/measure_system.dart';

class WorkoutConstants {
  const WorkoutConstants._();
  // =======================
  // --- Weight ---
  // =======================

  static const double minWeight = 0;

  /// Max 600 kg covers world records (e.g., Deadlift ~501kg) with a buffer.
  static const double _maxWeightMetric = 600;

  /// ~1325 lbs (approx. 600kg).
  static const double _maxWeightImperial = 1325;

  /// Metric step: 0.5 kg allows for micro-loading.
  static const double _weightStepMetric = 0.5;

  /// Imperial step: 1.0 lb is standard for UI pickers.
  static const double _weightStepImperial = 1;

  // --- Weight Helpers ---

  static double maxWeight(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _maxWeightMetric : _maxWeightImperial;
  }

  static double weightStep(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _weightStepMetric : _weightStepImperial;
  }

  // ===========================
  // --- Distance ---
  // ===========================

  static const double minDistance = 0;

  /// 200 km covers ultramarathons and long cycling sessions.
  static const double _maxDistanceMetric = 200;

  /// ~125 miles.
  static const double _maxDistanceImperial = 125;

  /// Step: 0.1 (100 meters).
  static const double distanceStep = 0.1;

  // --- Distance Helpers ---

  static double maxDistance(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _maxDistanceMetric : _maxDistanceImperial;
  }

  // ===========================
  // --- Speed ---
  // ===========================

  static const double minSpeed = 0;

  /// 50 km/h is sufficient for cycling; Usain Bolt peaks at ~44.72 km/h.
  static const double _maxSpeedMetric = 50;

  /// ~31 mph.
  static const double _maxSpeedImperial = 30;

  /// Step: 0.1.
  static const double speedStep = 0.1;

  // --- Speed Helpers ---

  static double maxSpeed(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _maxSpeedMetric : _maxSpeedImperial;
  }

  // --- Treadmill Speed ---

  /// Minimum supported treadmill speed.
  static const double _minTreadmillSpeedMetric = 0.8;

  /// Approximately 0.5 mph.
  static const double _minTreadmillSpeedImperial = 0.5;

  /// Maximum supported treadmill speed.
  static const double _maxTreadmillSpeedMetric = 20;

  /// Approximately 12.4 mph.
  static const double _maxTreadmillSpeedImperial = 12.4;

  static double minTreadmillSpeed(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _minTreadmillSpeedMetric : _minTreadmillSpeedImperial;
  }

  static double maxTreadmillSpeed(MeasurementSystem system) {
    return system == MeasurementSystem.metric ? _maxTreadmillSpeedMetric : _maxTreadmillSpeedImperial;
  }

  // =======================
  // --- Reps ---
  // =======================

  static const int minReps = 0;

  /// 500 reps covers high-volume calisthenics or jump rope sets.
  static const int maxReps = 500;

  static const int repsStep = 1;

  // =======================
  // --- Degrees (Geometry) ---
  // =======================

  /// -15 degrees for decline benches or treadmills.
  static const double minDegree = 0;

  /// 90 degrees for vertical bench press backrests.
  static const double maxDegree = 180;

  static const double degreeStep = 1;
}
