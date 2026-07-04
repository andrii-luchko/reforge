// ignore_for_file: discarded_futures

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:reforge/app/theme/app_theme.dart';
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
  required double t,
}) {
  final lat = from.latitude + (to.latitude - from.latitude) * t;
  final lng = from.longitude + (to.longitude - from.longitude) * t;

  var headingDiff = (to.heading - from.heading) % 360.0;
  if (headingDiff > 180.0) {
    headingDiff -= 360.0;
  } else if (headingDiff < -180.0) {
    headingDiff += 360.0;
  }
  final heading = (from.heading + headingDiff * t) % 360.0;

  return InterpolatedPosition(latitude: lat, longitude: lng, heading: heading);
}

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

  late final AnimationController _markerAnimController;
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
    )..addListener(_onMarkerAnimTick);

    if (widget.routeMap.isNotEmpty) {
      _oldPosition = widget.routeMap.last;
      _targetPosition = widget.routeMap.last;
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
    if (widget.routeMap.isEmpty) return;

    if (hasNewPoints) {
      _rebuildPolyline();
    }

    _handleLatestPositionChanged();

    if (_followUser && hasNewPoints) {
      _animateToLatest();
    }
  }

  void _onMarkerAnimTick() => setState(() {});

  void _rebuildPolyline() {
    _polylines = {
      Polyline(
        polylineId: const PolylineId('route'),
        points: widget.routeMap.map((p) => LatLng(p.latitude, p.longitude)).toList(),
        color: context.appTheme.orange100,
        width: 12,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  void _handleLatestPositionChanged() {
    final latest = widget.routeMap.last;
    final isSamePosition =
        _targetPosition != null &&
        _targetPosition!.latitude == latest.latitude &&
        _targetPosition!.longitude == latest.longitude;

    if (isSamePosition) return;

    _oldPosition = _targetPosition ?? latest;
    _targetPosition = latest;
    _markerAnimController.forward(from: 0);
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

  void _handleRecenterPressed() {
    setState(() {
      _followUser = true;
    });
    _animateToLatest();
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

    final position = _oldPosition != null && _targetPosition != null
        ? interpolateRoutePosition(
            from: _oldPosition!,
            to: _targetPosition!,
            t: _markerAnimController.value,
          )
        : InterpolatedPosition(
            latitude: widget.routeMap.last.latitude,
            longitude: widget.routeMap.last.longitude,
            heading: widget.routeMap.last.heading,
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
              onPressed: _handleRecenterPressed,
            ),
          ),
      ],
    );
  }
}
