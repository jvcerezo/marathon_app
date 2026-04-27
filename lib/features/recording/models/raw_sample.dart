/// Raw GPS reading straight from the location stream, before filtering.
class RawSample {
  final double lat;
  final double lon;
  final double? elevation;
  final double accuracy; // meters (lower is better)
  final double speed; // m/s reported by the GPS chip
  final DateTime timestamp;

  const RawSample({
    required this.lat,
    required this.lon,
    required this.accuracy,
    required this.speed,
    required this.timestamp,
    this.elevation,
  });
}
