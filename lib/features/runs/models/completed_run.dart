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

  /// Fastest contiguous split times in seconds, computed when the run
  /// was finalized. Null if the run wasn't long enough to contain a
  /// split of that distance (e.g. a 3km run has no 5K split).
  final double? bestSplit1kSec;
  final double? bestSplit5kSec;
  final double? bestSplit10kSec;
  final double? bestSplitHalfSec;
  final double? bestSplitMarathonSec;

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
    this.bestSplit1kSec,
    this.bestSplit5kSec,
    this.bestSplit10kSec,
    this.bestSplitHalfSec,
    this.bestSplitMarathonSec,
  });

  double get distanceKm => distanceM / 1000.0;

  /// Lookup by the milestone distances used in [kSplitDistancesM].
  double? bestSplitFor(int targetDistanceM) {
    switch (targetDistanceM) {
      case 1000:
        return bestSplit1kSec;
      case 5000:
        return bestSplit5kSec;
      case 10000:
        return bestSplit10kSec;
      case 21098:
        return bestSplitHalfSec;
      case 42195:
        return bestSplitMarathonSec;
      default:
        return null;
    }
  }
}
