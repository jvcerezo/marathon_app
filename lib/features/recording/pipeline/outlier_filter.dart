import '../../../core/math/geo_math.dart';
import '../models/raw_sample.dart';

/// Drops low-quality and physically-impossible GPS fixes.
class OutlierFilter {
  static const double _maxAccuracyM = 30.0;
  static const double _maxSpeedMps = 15.0; // ~54 km/h

  RawSample? _last;

  RawSample? accept(RawSample s) {
    if (s.accuracy > _maxAccuracyM) return null;

    final last = _last;
    if (last != null) {
      final dtSec = s.timestamp.difference(last.timestamp).inMilliseconds / 1000.0;
      if (dtSec <= 0) return null;
      final dist = haversineMeters(last.lat, last.lon, s.lat, s.lon);
      if (dist / dtSec > _maxSpeedMps) return null;
    }

    _last = s;
    return s;
  }
}
