import 'dart:math';

/// Encodes a list of (lat, lon) pairs to Google's Encoded Polyline Algorithm
/// (precision 5). Used to cache a compact polyline on the runs row.
String encodePolyline(List<({double lat, double lon})> points) {
  final buf = StringBuffer();
  int prevLat = 0;
  int prevLon = 0;

  for (final p in points) {
    final lat = (p.lat * 1e5).round();
    final lon = (p.lon * 1e5).round();
    _encodeValue(lat - prevLat, buf);
    _encodeValue(lon - prevLon, buf);
    prevLat = lat;
    prevLon = lon;
  }

  return buf.toString();
}

List<({double lat, double lon})> decodePolyline(String encoded) {
  final points = <({double lat, double lon})>[];
  int index = 0;
  int lat = 0;
  int lon = 0;

  while (index < encoded.length) {
    final dLat = _decodeValue(encoded, index);
    index = dLat.nextIndex;
    lat += dLat.value;

    final dLon = _decodeValue(encoded, index);
    index = dLon.nextIndex;
    lon += dLon.value;

    points.add((lat: lat / 1e5, lon: lon / 1e5));
  }

  return points;
}

void _encodeValue(int value, StringBuffer buf) {
  int v = value < 0 ? ~(value << 1) : value << 1;
  while (v >= 0x20) {
    buf.writeCharCode((0x20 | (v & 0x1f)) + 63);
    v >>= 5;
  }
  buf.writeCharCode(v + 63);
}

({int value, int nextIndex}) _decodeValue(String encoded, int start) {
  int shift = 0;
  int result = 0;
  int b;
  int index = start;
  do {
    b = encoded.codeUnitAt(index++) - 63;
    result |= (b & 0x1f) << shift;
    shift += 5;
  } while (b >= 0x20);
  final value = (result & 1) != 0 ? ~(result >> 1) : result >> 1;
  return (value: value, nextIndex: index);
}

/// Douglas-Peucker simplification. Tolerance in meters.
/// Returns a subset of input points preserving shape within tolerance.
List<({double lat, double lon})> simplify(
  List<({double lat, double lon})> points,
  double toleranceM,
) {
  if (points.length < 3) return List.of(points);
  final keep = List<bool>.filled(points.length, false);
  keep[0] = true;
  keep[points.length - 1] = true;
  _dp(points, 0, points.length - 1, toleranceM, keep);
  final result = <({double lat, double lon})>[];
  for (int i = 0; i < points.length; i++) {
    if (keep[i]) result.add(points[i]);
  }
  return result;
}

void _dp(
  List<({double lat, double lon})> pts,
  int start,
  int end,
  double tol,
  List<bool> keep,
) {
  double maxDist = 0;
  int maxIdx = -1;
  for (int i = start + 1; i < end; i++) {
    final d = _perpDistanceM(pts[i], pts[start], pts[end]);
    if (d > maxDist) {
      maxDist = d;
      maxIdx = i;
    }
  }
  if (maxDist > tol && maxIdx >= 0) {
    keep[maxIdx] = true;
    _dp(pts, start, maxIdx, tol, keep);
    _dp(pts, maxIdx, end, tol, keep);
  }
}

double _perpDistanceM(
  ({double lat, double lon}) p,
  ({double lat, double lon}) a,
  ({double lat, double lon}) b,
) {
  // Approximate using equirectangular projection at the segment midpoint.
  final midLat = (a.lat + b.lat) / 2;
  final cosLat = cos(midLat * pi / 180);
  final mPerDeg = 111320.0;

  final ax = a.lon * cosLat * mPerDeg;
  final ay = a.lat * mPerDeg;
  final bx = b.lon * cosLat * mPerDeg;
  final by = b.lat * mPerDeg;
  final px = p.lon * cosLat * mPerDeg;
  final py = p.lat * mPerDeg;

  final dx = bx - ax;
  final dy = by - ay;
  final lenSq = dx * dx + dy * dy;
  if (lenSq == 0) {
    return sqrt((px - ax) * (px - ax) + (py - ay) * (py - ay));
  }
  final t = ((px - ax) * dx + (py - ay) * dy) / lenSq;
  final clampedT = t.clamp(0.0, 1.0);
  final cx = ax + clampedT * dx;
  final cy = ay + clampedT * dy;
  return sqrt((px - cx) * (px - cx) + (py - cy) * (py - cy));
}
