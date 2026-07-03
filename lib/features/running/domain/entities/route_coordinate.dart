class RouteCoordinate {
  const RouteCoordinate({
    required this.latitude,
    required this.longitude,
  });

  final double latitude;
  final double longitude;

  @override
  String toString() => 'RouteCoordinate(lat: $latitude, lng: $longitude)';
}
