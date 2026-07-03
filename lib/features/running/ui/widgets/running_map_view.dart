import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';

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

class _RunningMapViewState extends State<RunningMapView> {
  GoogleMapController? _controller;
  BitmapDescriptor? _userLocationIcon;

  @override
  void initState() {
    super.initState();
    _initCustomMarker();
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
    if (widget.routeMap.length != oldWidget.routeMap.length && widget.routeMap.isNotEmpty) {
      _animateToLatest();
    }
  }

  void _animateToLatest() {
    if (_controller == null || widget.routeMap.isEmpty) return;
    final latest = widget.routeMap.last;
    _controller?.animateCamera(
      CameraUpdate.newLatLng(LatLng(latest.latitude, latest.longitude)),
    );
  }

  double _calculateBearing(RouteCoordinate start, RouteCoordinate end) {
    final lat1 = start.latitude * math.pi / 180.0;
    final lon1 = start.longitude * math.pi / 180.0;
    final lat2 = end.latitude * math.pi / 180.0;
    final lon2 = end.longitude * math.pi / 180.0;

    final dLon = lon2 - lon1;

    final y = math.sin(dLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final radians = math.atan2(y, x);
    // Convert radians to degrees and normalize to 0-360
    return (radians * 180.0 / math.pi + 360.0) % 360.0;
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
      width: 10,
    );

    final currentPosition = widget.routeMap.last;

    final currentHeading = widget.routeMap.length > 1
        ? _calculateBearing(widget.routeMap[widget.routeMap.length - 2], currentPosition)
        : 0.0;

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(currentPosition.latitude, currentPosition.longitude),
      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
      rotation: currentHeading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(currentPosition.latitude, currentPosition.longitude),
        zoom: 15.0,
      ),
      polylines: {polyline},
      markers: {userMarker},
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      buildingsEnabled: false,
      // Apply the custom JSON style here
      style: _darkMapStyle,
      onMapCreated: (controller) {
        _controller = controller;
      },
    );
  }
}
