import '../models/raw_sample.dart';

/// Independent 1D Kalman filters on lat and lon. At run-distance scale, the
/// axes are close enough to independent that a real 2D filter offers no
/// visible benefit and costs complexity.
class LocationSmoother {
  static const double _processNoise = 1e-5;

  double? _lat;
  double? _lon;
  double _variance = 1.0;

  ({double lat, double lon}) smooth(RawSample s) {
    final lat = _lat;
    final lon = _lon;
    if (lat == null || lon == null) {
      _lat = s.lat;
      _lon = s.lon;
      _variance = s.accuracy * s.accuracy;
      return (lat: s.lat, lon: s.lon);
    }

    _variance += _processNoise;
    final measurementVariance = s.accuracy * s.accuracy;
    final gain = _variance / (_variance + measurementVariance);

    final newLat = lat + gain * (s.lat - lat);
    final newLon = lon + gain * (s.lon - lon);
    _lat = newLat;
    _lon = newLon;
    _variance = (1 - gain) * _variance;
    return (lat: newLat, lon: newLon);
  }
}
