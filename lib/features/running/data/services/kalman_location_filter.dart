// ignore_for_file: prefer_int_literals

import 'dart:math' as math;

import 'package:reforge/features/running/constants/running_constants.dart';

enum KalmanUpdateResult { initialized, accepted, rejectedOutlier, ignoredStale }

/// A proper Kalman filter for GPS-based running tracking.
///
/// State model: constant-velocity motion in a local East-North tangent
/// plane (meters), state vector `[north, east, vNorth, vEast]`.
/// Uncertainty is tracked with a full 4x4 covariance matrix and updated
/// through the classic predict/update Kalman cycle (F, Q, H, R matrices).
///
/// This is deliberately implemented with small generic matrix helpers
/// rather than hand-unrolled scalar math, so the predict/update steps
/// read exactly like the textbook equations and are easy to audit.
class KalmanLocationFilter {
  /// Standard deviation of the assumed process (acceleration) noise,
  /// in m/s^2. This is *not* the runner's actual acceleration — it's how
  /// much unmodeled acceleration (surges, stops, direction changes) we
  /// expect between GPS updates.
  ///
  /// Lower values trust the constant-velocity motion model more
  /// (smoother track, more lag on direction/pace changes).
  /// Higher values trust raw GPS more (more responsive, more jittery).
  /// 1.5-3.0 is a reasonable range for running.
  KalmanLocationFilter({
    this.accelNoise = RunningConstants.kalmanAccelNoise,
    this.minAccuracy = RunningConstants.kalmanMinAccuracy,
    this.gatingThreshold = RunningConstants.kalmanGatingThreshold,
  });

  final double accelNoise;
  final double minAccuracy;

  /// Squared Mahalanobis distance threshold for rejecting a GPS fix as
  /// an outlier (multipath bounce, tunnel-exit spike, etc). 9.0 is
  /// roughly the 99th percentile for 2 degrees of freedom — only fixes
  /// that are wildly inconsistent with the motion model get rejected.
  final double gatingThreshold;

  // Local tangent-plane projection, anchored at the first fix of the run.
  double? _refLatDeg;
  double? _refLngDeg;
  double? _metersPerDegLat;
  double? _metersPerDegLng;

  // State vector: [north, east, vNorth, vEast] (meters, meters/sec)
  List<double>? _x;

  // 4x4 state covariance matrix.
  List<List<double>>? _p;

  int? _timestampMs;

  /// Resets the filter's state. Call this when a new tracking session starts.
  void reset() {
    _refLatDeg = null;
    _refLngDeg = null;
    _metersPerDegLat = null;
    _metersPerDegLng = null;
    _x = null;
    _p = null;
    _timestampMs = null;
  }

  /// Processes a raw GPS point and updates the internal filtered state.
  KalmanUpdateResult process({
    required double lat,
    required double lng,
    required double accuracy,
    required int timestampMs,
  }) {
    final safeAccuracy = math.max(accuracy, minAccuracy);
    final r = safeAccuracy * safeAccuracy;

    // Cold start: anchor the local plane and initialize state/covariance.
    if (_x == null) {
      _refLatDeg = lat;
      _refLngDeg = lng;
      _metersPerDegLat = 111320.0;
      _metersPerDegLng = 111320.0 * math.cos(lat * math.pi / 180.0);

      _x = [0.0, 0.0, 0.0, 0.0];
      _p = [
        [r, 0.0, 0.0, 0.0],
        [0.0, r, 0.0, 0.0],
        [0.0, 0.0, 4.0, 0.0], // ~2 m/s stddev initial velocity uncertainty
        [0.0, 0.0, 0.0, 4.0],
      ];
      _timestampMs = timestampMs;
      return KalmanUpdateResult.initialized;
    }

    final dtMs = timestampMs - _timestampMs!;
    if (dtMs <= 0) return KalmanUpdateResult.ignoredStale;
    final dt = dtMs / 1000.0;

    // Project the raw fix into the local ENU meter plane.
    final zNorth = (lat - _refLatDeg!) * _metersPerDegLat!;
    final zEast = (lng - _refLngDeg!) * _metersPerDegLng!;

    // State transition: constant-velocity model.
    final f = [
      [1.0, 0.0, dt, 0.0],
      [0.0, 1.0, 0.0, dt],
      [0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 1.0],
    ];

    // Measurement matrix: we only observe position, not velocity.
    final h = [
      [1.0, 0.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 0.0],
    ];

    // Process noise: discretized continuous white-noise-acceleration model.
    final sigma2 = accelNoise * accelNoise;
    final dt2 = dt * dt;
    final dt3 = dt2 * dt;
    final dt4 = dt3 * dt;
    final q = [
      [sigma2 * dt4 / 4, 0.0, sigma2 * dt3 / 2, 0.0],
      [0.0, sigma2 * dt4 / 4, 0.0, sigma2 * dt3 / 2],
      [sigma2 * dt3 / 2, 0.0, sigma2 * dt2, 0.0],
      [0.0, sigma2 * dt3 / 2, 0.0, sigma2 * dt2],
    ];

    final rMat = [
      [r, 0.0],
      [0.0, r],
    ];

    // ---------------- PREDICT ----------------
    final xPred = _matVec(f, _x!);
    final pPred = _matAdd(_matMul(_matMul(f, _p!), _transpose(f)), q);

    // ---------------- INNOVATION ----------------
    final zVec = [zNorth, zEast];
    final y = _subVec(zVec, _matVec(h, xPred));
    final s = _matAdd(_matMul(_matMul(h, pPred), _transpose(h)), rMat);
    final sInv = _invert2x2(s);

    final mahalanobisSq =
        y[0] * (sInv[0][0] * y[0] + sInv[0][1] * y[1]) + y[1] * (sInv[1][0] * y[0] + sInv[1][1] * y[1]);

    if (mahalanobisSq > gatingThreshold) {
      // This fix is wildly inconsistent with the motion model (GPS glitch,
      // multipath off a building, tunnel-exit spike). Trust the prediction
      // instead of letting the outlier corrupt the track.
      _x = xPred;
      _p = pPred;
      _timestampMs = timestampMs;
      return KalmanUpdateResult.rejectedOutlier;
    }

    // ---------------- UPDATE ----------------
    final k = _matMul(_matMul(pPred, _transpose(h)), sInv); // 4x2 Kalman gain
    _x = _addVec(xPred, _matVec(k, y));
    _p = _matMul(_matSub(_identity(4), _matMul(k, h)), pPred);
    _timestampMs = timestampMs;
    return KalmanUpdateResult.accepted;
  }

  /// The currently filtered latitude.
  double get latitude => _x == null ? 0.0 : _refLatDeg! + _x![0] / _metersPerDegLat!;

  /// The currently filtered longitude.
  double get longitude => _x == null ? 0.0 : _refLngDeg! + _x![1] / _metersPerDegLng!;

  /// Filtered speed, derived from the velocity state (meters/sec).
  /// Smoother than computing speed from raw distance/time deltas.
  double get speedMetersPerSecond {
    if (_x == null) return 0.0;
    return math.sqrt(_x![2] * _x![2] + _x![3] * _x![3]);
  }

  /// Heading in degrees [0, 360), derived from the filter's velocity vector.
  double get heading {
    if (_x == null || (_x![2] == 0 && _x![3] == 0)) return 0.0;
    final radians = math.atan2(_x![3], _x![2]); // atan2(east, north)
    return (radians * 180.0 / math.pi + 360.0) % 360.0;
  }

  /// 1-sigma position uncertainty in meters. Handy for drawing an
  /// "accuracy circle" around the runner's position on the map.
  double get positionUncertaintyMeters {
    if (_p == null) return 0.0;
    return math.sqrt(_p![0][0] + _p![1][1]);
  }

  /// Whether the filter has received its first point.
  bool get hasValidState => _x != null;

  // ---------------- Matrix helpers ----------------

  List<List<double>> _matMul(List<List<double>> a, List<List<double>> b) {
    final rows = a.length;
    final inner = b.length;
    final cols = b[0].length;
    final result = List.generate(rows, (_) => List<double>.filled(cols, 0.0));

    for (var i = 0; i < rows; i++) {
      for (var j = 0; j < cols; j++) {
        var sum = 0.0;
        for (var k = 0; k < inner; k++) {
          sum += a[i][k] * b[k][j];
        }
        result[i][j] = sum;
      }
    }
    return result;
  }

  List<double> _matVec(List<List<double>> a, List<double> v) {
    return List.generate(a.length, (i) {
      var sum = 0.0;
      for (var j = 0; j < v.length; j++) {
        sum += a[i][j] * v[j];
      }
      return sum;
    });
  }

  List<List<double>> _transpose(List<List<double>> a) {
    final rows = a.length;
    final cols = a[0].length;
    return List.generate(cols, (j) => List.generate(rows, (i) => a[i][j]));
  }

  List<List<double>> _matAdd(List<List<double>> a, List<List<double>> b) {
    return List.generate(
      a.length,
      (i) => List.generate(a[i].length, (j) => a[i][j] + b[i][j]),
    );
  }

  List<List<double>> _matSub(List<List<double>> a, List<List<double>> b) {
    return List.generate(
      a.length,
      (i) => List.generate(a[i].length, (j) => a[i][j] - b[i][j]),
    );
  }

  List<double> _addVec(List<double> a, List<double> b) => List.generate(a.length, (i) => a[i] + b[i]);

  List<double> _subVec(List<double> a, List<double> b) => List.generate(a.length, (i) => a[i] - b[i]);

  List<List<double>> _identity(int n) => List.generate(n, (i) => List.generate(n, (j) => i == j ? 1.0 : 0.0));

  List<List<double>> _invert2x2(List<List<double>> m) {
    final a = m[0][0];
    final b = m[0][1];
    final c = m[1][0];
    final d = m[1][1];
    final det = a * d - b * c;
    final safeDet = det.abs() < 1e-12 ? 1e-12 : det;
    final invDet = 1.0 / safeDet;
    return [
      [d * invDet, -b * invDet],
      [-c * invDet, a * invDet],
    ];
  }
}
