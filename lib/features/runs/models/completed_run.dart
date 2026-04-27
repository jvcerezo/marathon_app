class CompletedRun {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double distanceM;
  final int movingTimeSec;
  final int elapsedTimeSec;
  final double? avgPaceSecPerKm;
  final double elevationGainM;
  final String? encodedPolyline;
  final String source;
  final String? matchedSessionId;

  const CompletedRun({
    required this.id,
    required this.startedAt,
    required this.distanceM,
    required this.movingTimeSec,
    required this.elapsedTimeSec,
    required this.elevationGainM,
    required this.source,
    this.endedAt,
    this.avgPaceSecPerKm,
    this.encodedPolyline,
    this.matchedSessionId,
  });

  double get distanceKm => distanceM / 1000.0;
}
