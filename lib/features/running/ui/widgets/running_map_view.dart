// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/features/running/ui/widgets/map_styles.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

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

  Set<Polyline> _polylines = {};

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
      _rebuildPolyline();
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

  void _rebuildPolyline() {
    final appTheme = context.appTheme;
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routeMap.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: appTheme.orange100,
        width: 12,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  @override
  void didUpdateWidget(RunningMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasChanged = widget.routeMap.length != oldWidget.routeMap.length;

    if (hasChanged) {
      _rebuildPolyline();
    }

    if (widget.routeMap.isNotEmpty) {
      _handleNewPosition(widget.routeMap.last);
    }

    if (hasChanged) {
      _maybeFollowCamera();
    }
  }

  void _handleNewPosition(RouteCoordinate latest) {
    if (_targetPosition == null ||
        _targetPosition!.latitude != latest.latitude ||
        _targetPosition!.longitude != latest.longitude) {
      _oldPosition = _targetPosition ?? latest;
      _targetPosition = latest;

      _markerAnimController.forward(from: 0);
    }
  }

  void _maybeFollowCamera() {
    if (_followUser && widget.routeMap.isNotEmpty) {
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

    _InterpolatedPosition interpolated;

    if (_oldPosition != null && _targetPosition != null) {
      interpolated = _interpolate(_oldPosition!, _targetPosition!, _markerAnimController.value);
    } else {
      final currentPosition = widget.routeMap.last;
      interpolated = _InterpolatedPosition(
        currentPosition.latitude,
        currentPosition.longitude,
        currentPosition.heading,
      );
    }

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(interpolated.lat, interpolated.lng),
      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
      rotation: interpolated.heading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(interpolated.lat, interpolated.lng),
            zoom: RunningConstants.mapCameraZoomActive,
          ),
          polylines: _polylines,
          markers: {userMarker},
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          buildingsEnabled: false,
          compassEnabled: false,
          style: darkMapStyle,
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

class _InterpolatedPosition {
  const _InterpolatedPosition(this.lat, this.lng, this.heading);
  final double lat;
  final double lng;
  final double heading;
}

_InterpolatedPosition _interpolate(RouteCoordinate from, RouteCoordinate to, double t) {
  final lat = from.latitude + (to.latitude - from.latitude) * t;
  final lng = from.longitude + (to.longitude - from.longitude) * t;
  var diff = (to.heading - from.heading) % 360.0;
  if (diff > 180.0) diff -= 360.0;
  if (diff < -180.0) diff += 360.0;
  return _InterpolatedPosition(lat, lng, (from.heading + diff * t) % 360.0);
}
