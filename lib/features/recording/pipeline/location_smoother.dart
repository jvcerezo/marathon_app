import 'dart:math';

import '../models/raw_sample.dart';

/// Independent 1D Kalman filters on lat and lon.
///
/// Process noise is **speed-adaptive and time-aware**: variance grows by
/// `max(speedFloor, reportedSpeed)² × Δt` between updates. That means the
/// filter trusts new measurements aggressively while the runner is moving
/// (high gain) and locks position when stationary (low gain). A constant
/// per-step Q is wrong for GPS smoothing — when set too small, the filter's
/// variance collapses and gain trends toward zero, causing the smoothed
/// track to freeze even as the user keeps running.
class LocationSmoother {
  /// Floor on speed used for Q. Keeps the filter responsive even when the
  /// GPS chip momentarily reports speed≈0 mid-stride.
  static const double _minSpeedMps = 0.5;

  /// Floor on measurement variance (R). Stops gain from collapsing on
  /// suspiciously-confident fixes.
  static const double _minMeasurementVarianceM2 = 4.0;

  /// Cap on Δt used in the prediction step. Long GPS dropouts otherwise
  /// inflate variance to the point where the next sample is taken whole,
  /// which lets a single bad fix drag the smoothed track.
  static const double _maxDtSec = 5.0;

  double? _lat;
  double? _lon;
  double _variance = 1.0;
  DateTime? _lastTimestamp;

  ({double lat, double lon}) smooth(RawSample s) {
    final lat = _lat;
    final lon = _lon;
    if (lat == null || lon == null || _lastTimestamp == null) {
      _lat = s.lat;
      _lon = s.lon;
      _variance = max(s.accuracy * s.accuracy, _minMeasurementVarianceM2);
      _lastTimestamp = s.timestamp;
      return (lat: s.lat, lon: s.lon);
    }

    final rawDtSec =
        s.timestamp.difference(_lastTimestamp!).inMilliseconds / 1000.0;
    final dtSec = rawDtSec.clamp(0.0, _maxDtSec);

    // Q (process variance per second) ≈ expected positional drift². For
    // a runner at 3 m/s this is ~9 m²/s, which yields a steady-state gain
    // around 0.25 — enough to track real motion, smooth enough to reject
    // single-sample jitter.
    final speed = max(_minSpeedMps, s.speed.abs());
    final qPerSec = speed * speed;
    _variance += qPerSec * dtSec;

    final r = max(s.accuracy * s.accuracy, _minMeasurementVarianceM2);
    final gain = _variance / (_variance + r);

    final newLat = lat + gain * (s.lat - lat);
    final newLon = lon + gain * (s.lon - lon);
    _lat = newLat;
    _lon = newLon;
    _variance = (1 - gain) * _variance;
    _lastTimestamp = s.timestamp;
    return (lat: newLat, lon: newLon);
  }
}
