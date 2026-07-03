import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/domain/entities/running_metrics.dart';
import 'package:reforge/features/running/domain/services/tracking_engine.dart';

@Injectable(as: TrackingEngine)
@Named('gps')
class GpsTrackingEngine implements TrackingEngine {
  final _controller = StreamController<RunningMetrics>.broadcast();
  
  Timer? _ticker;
  StreamSubscription<Position>? _positionSub;

  double _totalDistance = 0;
  int _durationSec = 0;
  Position? _lastValidPosition;
  bool _isPaused = false;

  @override
  Stream<RunningMetrics> get metricsStream => _controller.stream;

  @override
  Future<void> start({RunningMetrics? initialOffset}) async {
    if (initialOffset != null) {
      _totalDistance = initialOffset.distanceMeters;
      _durationSec = initialOffset.durationSeconds;
    }
    
    _isPaused = false;
    _lastValidPosition = null;

    // Start 1-sec ticker for time and pace updates
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused) return;
      _durationSec++;
      _emitMetrics();
    });

    // Start GPS stream
    await _positionSub?.cancel();
    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // only update if moved > 2m
      ),
    ).listen((Position pos) {
      if (_isPaused) return;
      
      // Filter out bad accuracy coordinates
      if (pos.accuracy > 20) return; 

      if (_lastValidPosition == null) {
        _lastValidPosition = pos;
        return;
      }

      final distanceDelta = Geolocator.distanceBetween(
        _lastValidPosition!.latitude,
        _lastValidPosition!.longitude,
        pos.latitude,
        pos.longitude,
      );

      if (distanceDelta > 2.0) {
        _totalDistance += distanceDelta;
        _lastValidPosition = pos;
        
        // Emit immediately to make the map and metrics feel responsive
        _emitMetrics();
      }
    });
  }

  void _emitMetrics() {
    final distanceKm = _totalDistance / 1000.0;
    final durationHours = _durationSec / 3600.0;
    final paceKmH = (durationHours > 0) ? (distanceKm / durationHours) : 0.0;

    _controller.add(RunningMetrics(
      distanceMeters: _totalDistance,
      durationSeconds: _durationSec,
      paceKmH: paceKmH,
      stepCount: 0, // GPS engine doesn't track steps
      currentLocation: _lastValidPosition != null 
          ? RouteCoordinate(
              latitude: _lastValidPosition!.latitude, 
              longitude: _lastValidPosition!.longitude,
            )
          : null,
    ));
  }

  @override
  void pause() {
    _isPaused = true;
  }

  @override
  void resume() {
    _isPaused = false;
  }

  @override
  void stop() {
    _ticker?.cancel();
    _positionSub?.cancel();
  }

  @override
  void reset() {
    _totalDistance = 0;
    _durationSec = 0;
    _lastValidPosition = null;
  }
}
