import 'geo_math.dart';

/// Distances we track personal records for, in meters. Mirrors typical
/// Strava splits: 1K, 5K, 10K, half, marathon.
const List<int> kSplitDistancesM = <int>[1000, 5000, 10000, 21098, 42195];

/// Computes the fastest contiguous split of [targetDistanceM] within a
/// run. Walks a two-pointer sliding window over the samples, tracking
/// the cumulative distance via Haversine and returning the smallest
/// elapsed time over any window covering at least [targetDistanceM].
///
/// Returns `null` if the run wasn't long enough to contain a split of
/// the requested distance.
///
/// `samples` is expected to be ordered chronologically; each item is
/// (lat, lon, tOffsetMs) where tOffsetMs is the run-clock offset since
/// recording started.
double? bestSplitSec({
  required List<({double lat, double lon, int tOffsetMs})> samples,
  required int targetDistanceM,
}) {
  if (samples.length < 2) return null;

  // Pre-compute cumulative distance at each sample. O(n) one-pass with
  // Haversine between consecutive samples.
  final cumulative = List<double>.filled(samples.length, 0);
  for (int i = 1; i < samples.length; i++) {
    cumulative[i] = cumulative[i - 1] +
        haversineMeters(
          samples[i - 1].lat,
          samples[i - 1].lon,
          samples[i].lat,
          samples[i].lon,
        );
  }
  if (cumulative.last < targetDistanceM) return null;

  // Two-pointer scan. For each `end`, advance `start` to the latest
  // index where the window still covers >= targetDistanceM. The
  // tightest window for that end is recorded; the global minimum
  // across all ends is the best split.
  double bestTimeSec = double.infinity;
  int start = 0;
  for (int end = 1; end < samples.length; end++) {
    while (start + 1 < end &&
        cumulative[end] - cumulative[start + 1] >= targetDistanceM) {
      start += 1;
    }
    if (cumulative[end] - cumulative[start] >= targetDistanceM) {
      final timeSec =
          (samples[end].tOffsetMs - samples[start].tOffsetMs) / 1000.0;
      if (timeSec > 0 && timeSec < bestTimeSec) {
        bestTimeSec = timeSec;
      }
    }
  }
  return bestTimeSec.isFinite ? bestTimeSec : null;
}

/// Convenience: compute best splits for every distance in
/// [kSplitDistancesM] in one pass over the sample list.
Map<int, double?> bestSplits(
    List<({double lat, double lon, int tOffsetMs})> samples) {
  final out = <int, double?>{};
  for (final d in kSplitDistancesM) {
    out[d] = bestSplitSec(samples: samples, targetDistanceM: d);
  }
  return out;
}
