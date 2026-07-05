// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/map_styles.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

@immutable
class InterpolatedPosition {
  const InterpolatedPosition({
    required this.latitude,
    required this.longitude,
    required this.heading,
  });

  final double latitude;
  final double longitude;
  final double heading;
}

InterpolatedPosition interpolateRoutePosition({
  required RouteCoordinate from,
  required RouteCoordinate to,
  required double fromHeading,
  required double toHeading,
  required double t,
}) {
  final lat = from.latitude + (to.latitude - from.latitude) * t;
  final lng = from.longitude + (to.longitude - from.longitude) * t;

  var headingDiff = (toHeading - fromHeading) % 360.0;
  if (headingDiff > 180.0) {
    headingDiff -= 360.0;
  } else if (headingDiff < -180.0) {
    headingDiff += 360.0;
  }
  final heading = (fromHeading + headingDiff * t) % 360.0;

  return InterpolatedPosition(latitude: lat, longitude: lng, heading: heading);
}

class RunningMapView extends StatefulWidget {
  const RunningMapView({
    required this.routeMap,
    this.currentLocation,
    this.heading = 0.0,
    this.isFollowingUser = false,
    this.onCameraMoveStarted,
    this.onRecenterPressed,
    super.key,
  });

  final List<RouteCoordinate> routeMap;
  final RouteCoordinate? currentLocation;
  final double heading;
  final bool isFollowingUser;
  final VoidCallback? onCameraMoveStarted;
  final VoidCallback? onRecenterPressed;

  @override
  State<RunningMapView> createState() => _RunningMapViewState();
}

class _RunningMapViewState extends State<RunningMapView> with SingleTickerProviderStateMixin {
  GoogleMapController? _controller;
  BitmapDescriptor? _userLocationIcon;

  late final AnimationController _markerAnimController;
  RouteCoordinate? _oldPosition;
  RouteCoordinate? _targetPosition;

  double _oldHeading = 0;
  double _targetHeading = 0;

  Set<Polyline> _polylines = {};
  bool _isProgrammaticMovement = false;

  @override
  void initState() {
    super.initState();
    _initCustomMarker();

    _markerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(_onMarkerAnimTick);

    _targetPosition = widget.currentLocation ?? widget.routeMap.lastOrNull;
    _oldPosition = _targetPosition;
    _targetHeading = widget.heading;
    _oldHeading = widget.heading;

    if (widget.routeMap.isNotEmpty) {
      _rebuildPolyline(widget.routeMap);
    }
  }

  @override
  void dispose() {
    _markerAnimController
      ..removeListener(_onMarkerAnimTick)
      ..dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(RunningMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasNewPoints = widget.routeMap.length != oldWidget.routeMap.length;
    if (hasNewPoints) {
      _rebuildPolyline(widget.routeMap);
    }

    final latest = widget.currentLocation;
    final heading = widget.heading;

    if (latest == null) return;

    final isSamePosition =
        _targetPosition != null &&
        _targetPosition!.latitude == latest.latitude &&
        _targetPosition!.longitude == latest.longitude;

    final headingDiff = (heading - _targetHeading).abs();
    final headingChanged = headingDiff > 1.0 && headingDiff < 359.0;

    if (!isSamePosition || headingChanged) {
      _oldPosition = _targetPosition ?? latest;
      _targetPosition = latest;

      _oldHeading = _targetHeading;
      _targetHeading = heading;

      _markerAnimController.forward(from: 0);
    }

    // Only animate camera if following user and (new point OR heading changed)
    // If it's a new point, we want to slide the camera there.
    // If heading changed, we want to rotate camera.
    if (widget.isFollowingUser && (!isSamePosition || headingChanged)) {
      _animateToLatest(latest, heading);
    } else if (widget.isFollowingUser && !oldWidget.isFollowingUser) {
      // User just pressed recenter button
      _animateToLatest(latest, heading);
    }
  }

  void _onMarkerAnimTick() => setState(() {});

  void _rebuildPolyline(List<RouteCoordinate> points) {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: context.appTheme.orange100,
        width: 12,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  Future<void> _initCustomMarker() async {
    final icon = await BitmapDescriptor.asset(
      width: 40,
      height: 78,
      const ImageConfiguration(size: Size(40, 78)),
      Assets.images.png.userPointer.path,
    );

    if (mounted) {
      setState(() {
        _userLocationIcon = icon;
      });
    }
  }

  void _animateToLatest(RouteCoordinate latest, double heading) {
    if (_controller == null) return;

    _isProgrammaticMovement = true;
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latest.latitude, latest.longitude),
          zoom: RunningConstants.mapCameraZoomActive,
          bearing: heading,
        ),
      ),
    );
  }

  void _handleCameraMoveStarted() {
    if (_isProgrammaticMovement) {
      _isProgrammaticMovement = false;
      return;
    }

    if (widget.isFollowingUser) {
      widget.onCameraMoveStarted?.call();
    }
  }

  void _handleRecenterPressed() {
    widget.onRecenterPressed?.call();

    if (widget.currentLocation != null) {
      _animateToLatest(widget.currentLocation!, widget.heading);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    if (widget.routeMap.isEmpty && widget.currentLocation == null) {
      return Container(
        color: appTheme.beige800,
      );
    }

    final position = _oldPosition != null && _targetPosition != null
        ? interpolateRoutePosition(
            from: _oldPosition!,
            to: _targetPosition!,
            fromHeading: _oldHeading,
            toHeading: _targetHeading,
            t: _markerAnimController.value,
          )
        : InterpolatedPosition(
            latitude: widget.currentLocation?.latitude ?? widget.routeMap.last.latitude,
            longitude: widget.currentLocation?.longitude ?? widget.routeMap.last.longitude,
            heading: widget.heading,
          );

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(position.latitude, position.longitude),
      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
      rotation: position.heading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: RunningConstants.mapCameraZoomActive,
            bearing: widget.heading, // Start map with initial heading
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
            logger.d('RunningMapView: GoogleMap created');
            _controller = controller;
          },
          onCameraMoveStarted: _handleCameraMoveStarted,
        ),
        if (!widget.isFollowingUser && widget.currentLocation != null)
          Positioned(
            bottom: 20,
            right: 16,
            child: AppIconButton(
              iconAsset: Assets.images.icons.myLocation,
              onPressed: _handleRecenterPressed,
            ),
          ),
      ],
    );
  }
}
