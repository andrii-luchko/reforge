// ignore_for_file: discarded_futures

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
import 'package:reforge/app/utils/logger/logger.dart';
import 'package:reforge/features/running/constants/map_styles.dart';
import 'package:reforge/features/running/constants/running_constants.dart';
import 'package:reforge/features/running/domain/entities/route_coordinate.dart';
import 'package:reforge/generated/flutter_gen/assets.gen.dart';
import 'package:reforge/shared/uikit/buttons/icon_button.dart';

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

class _RunningMapViewState extends State<RunningMapView> {
  GoogleMapController? _controller;
  BitmapDescriptor? _userLocationIcon;

  double _lat = 0;
  double _lng = 0;
  double _markerHeading = 0;

  bool _hasPosition = false;

  Set<Polyline> _polylines = {};
  bool _isProgrammaticMovement = false;
  Timer? _polylineDelayTimer;

  @override
  void dispose() {
    _polylineDelayTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initCustomMarker();

    final initial = widget.currentLocation ?? widget.routeMap.lastOrNull;
    if (initial != null) {
      _lat = initial.latitude;
      _lng = initial.longitude;
      _hasPosition = true;
    }
    _markerHeading = widget.heading;

    if (widget.routeMap.isNotEmpty) {
      _rebuildPolyline(widget.routeMap);
    }
  }

  @override
  void didUpdateWidget(RunningMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final hasNewPoints = widget.routeMap.length != oldWidget.routeMap.length;
    if (hasNewPoints) {
      _polylineDelayTimer?.cancel();
      _polylineDelayTimer = Timer(const Duration(milliseconds: 900), () {
        if (mounted) {
          setState(() {
            _rebuildPolyline(widget.routeMap);
          });
        }
      });
    }

    final latest = widget.currentLocation;
    final heading = widget.heading;

    if (latest == null) return;

    final isSamePosition = _lat == latest.latitude && _lng == latest.longitude;
    final headingDiff = (heading - _markerHeading).abs();
    final headingChanged = headingDiff > 1.0 && headingDiff < 359.0;

    if (!isSamePosition || headingChanged || !_hasPosition) {
      _lat = latest.latitude;
      _lng = latest.longitude;
      _markerHeading = heading;
      _hasPosition = true;
      setState(() {});
    }

    if (widget.isFollowingUser && (!isSamePosition || headingChanged)) {
      _animateToLatest(latest, heading);
    } else if (widget.isFollowingUser && !oldWidget.isFollowingUser) {
      _animateToLatest(latest, heading);
    }
  }

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

    final lat = _hasPosition ? _lat : widget.currentLocation?.latitude ?? widget.routeMap.last.latitude;
    final lng = _hasPosition ? _lng : widget.currentLocation?.longitude ?? widget.routeMap.last.longitude;
    final heading = _hasPosition ? _markerHeading : widget.heading;

    final userMarker = Marker(
      markerId: const MarkerId('user_current_location'),
      position: LatLng(lat, lng),
      icon: _userLocationIcon ?? BitmapDescriptor.defaultMarker,
      rotation: heading,
      flat: true,
      anchor: const Offset(0.5, 0.5),
    );

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(lat, lng),
            zoom: RunningConstants.mapCameraZoomActive,
            bearing: widget.heading,
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
