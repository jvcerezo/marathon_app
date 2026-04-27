/// Cleaned GPS sample after filter + smoother. This is what gets persisted.
class RunSample {
  final double lat;
  final double lon;
  final double? elevation;
  final int tOffsetMs; // ms since run start
  final double instantSpeed; // m/s

  const RunSample({
    required this.lat,
    required this.lon,
    required this.tOffsetMs,
    required this.instantSpeed,
    this.elevation,
  });
}
