class RouteCoordinate {
  const RouteCoordinate({
    required this.latitude,
    required this.longitude,
    this.heading = 0.0,
  });

  final double latitude;
  final double longitude;
  final double heading;

  @override
  String toString() => 'RouteCoordinate(lat: $latitude, lng: $longitude, heading: $heading)';
}
