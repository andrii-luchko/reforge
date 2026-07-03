// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

const String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#212121"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#757575"}]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{"color": "#212121"}]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [{"color": "#757575"}, {"visibility": "off"}]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#262626"}]
  },
  {
    "featureType": "poi",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [{"color": "#2c2c2c"}]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{"color": "#8a8a8a"}]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{"color": "#373737"}]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{"color": "#3c3c3c"}]
  },
  {
    "featureType": "transit",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#111111"}]
  }
]
''';

class RunningMapView extends StatefulWidget {
  const RunningMapView({
    required this.routeMap,
    super.key,
  });

  final List<RouteCoordinate> routeMap;

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  BitmapDescriptor? _userLocationIcon;

  late AnimationController _markerAnimController;
  RouteCoordinate? _oldPosition;
  RouteCoordinate? _targetPosition;

  bool _followUser = true;
  bool _isProgrammaticMovement = false;

  @override
  void initState() {
    super.initState();
    _initCustomMarker();

    _markerAnimController = AnimationController(
      vsync: this,
      duration: RunningConstants.engineTickInterval,
    )..addListener(() {
          setState(() {});
        });

    if (widget.routeMap.isNotEmpty) {
      _oldPosition = widget.routeMap.last;
      _targetPosition = widget.routeMap.last;
    }
  }

  @override
  void dispose() {
    _markerAnimController.dispose();
    super.dispose();
  }

  Future<void> _initCustomMarker() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(40, 40)),
      Assets.images.png.userPointer.path,
    );

    if (mounted) {
      setState(() {
        _userLocationIcon = icon;
      });
    }
  }

  @override
  void didUpdateWidget(RunningMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasChanged = widget.routeMap.length != oldWidget.routeMap.length;

    if (widget.routeMap.isNotEmpty) {
      final latest = widget.routeMap.last;
      if (_targetPosition == null ||
          _targetPosition!.latitude != latest.latitude ||
          _targetPosition!.longitude != latest.longitude) {
        _oldPosition = _targetPosition ?? latest;
        _targetPosition = latest;

        _markerAnimController.forward(from: 0);
      }
    }

    if (_followUser && widget.routeMap.isNotEmpty && hasChanged) {
      _animateToLatest();
    }
  }

  void _animateToLatest() {
    if (_controller == null || widget.routeMap.isEmpty) return;
    final latest = widget.routeMap.last;

    _isProgrammaticMovement = true;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latest.latitude, latest.longitude),
          zoom: RunningConstants.mapCameraZoomActive,
          bearing: latest.heading,
        ),
      ),
    );
  }

  void _handleCameraMoveStarted() {
    if (_isProgrammaticMovement) {
      _isProgrammaticMovement = false;
      return;
    }

    if (_followUser) {
      setState(() {
        _followUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    if (widget.routeMap.isEmpty) {
      return ColoredBox(
        color: appTheme.beige800,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: widget.routeMap.map((p) => LatLng(p.latitude, p.longitude)).toList(),
      color: appTheme.orange100,
      width: 12,
      jointType: JointType.round,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    double currentLat;
    double currentLng;
    double currentHeading;

    if (_oldPosition != null && _targetPosition != null) {
      final t = _markerAnimController.value;
      currentLat = _oldPosition!.latitude + (_targetPosition!.latitude - _oldPosition!.latitude) * t;
      currentLng = _oldPosition!.longitude + (_targetPosition!.longitude - _oldPosition!.longitude) * t;

      final oldH = _oldPosition!.heading;
      final newH = _targetPosition!.heading;
      var diff = (newH - oldH) % 360.0;
      if (diff > 180.0) {
        diff -= 360.0;
      } else if (diff < -180.0) {
        diff += 360.0;
      }
      currentHeading = (oldH + diff * t) % 360.0;
    } else {
      final currentPosition = widget.routeMap.last;
      currentLat = currentPosition.latitude;
      currentLng = currentPosition.longitude;
      currentHeading = currentPosition.heading;
    }

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(currentLat, currentLng),
      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
      rotation: currentHeading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(currentLat, currentLng),
            zoom: RunningConstants.mapCameraZoomActive,
          ),
          polylines: {polyline},
          markers: {userMarker},
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          buildingsEnabled: false,
          compassEnabled: false,
          style: _darkMapStyle,
          onMapCreated: (controller) {
            _controller = controller;
          },

          onCameraMoveStarted: _handleCameraMoveStarted,
        ),

        if (!_followUser)
          Positioned(
            bottom: 20,
            right: 16,
            child: AppIconButton(
              iconAsset: Assets.images.icons.myLocation,
              onPressed: () {
                setState(() {
                  _followUser = true;
                });
                _animateToLatest();
              },
            ),
          ),
      ],
    );
  }
}
