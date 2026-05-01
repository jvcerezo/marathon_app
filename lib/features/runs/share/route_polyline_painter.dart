import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

/// Renders a GPS route as a flat polyline on a canvas, scaled to fit the
/// available size with consistent padding. No map tiles — this is the
/// stylized "route shape" rendering used on the share card, where the
/// path itself is the hero element.
class RoutePolylinePainter extends CustomPainter {
  final List<LatLng> points;
  final Color lineColor;
  final Color startColor;
  final Color endColor;
  final double strokeWidth;
  final double padding;

  const RoutePolylinePainter({
    required this.points,
    required this.lineColor,
    required this.startColor,
    required this.endColor,
    this.strokeWidth = 6,
    this.padding = 24,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    // Find geographic bounds.
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLon = points.first.longitude;
    double maxLon = points.first.longitude;
    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLon) minLon = p.longitude;
      if (p.longitude > maxLon) maxLon = p.longitude;
    }

    // Scale longitude by cos(lat) so the rendered shape matches the real
    // ground shape — without this, routes near the equator look squashed.
    final centerLat = (minLat + maxLat) / 2;
    final cosLat = cos(centerLat * pi / 180);
    final latRange = max(maxLat - minLat, 1e-9);
    final lonRange = max((maxLon - minLon) * cosLat, 1e-9);

    final availW = size.width - 2 * padding;
    final availH = size.height - 2 * padding;
    final scale = min(availW / lonRange, availH / latRange);

    final centerLon = (minLon + maxLon) / 2;

    Offset toCanvas(LatLng p) {
      final dx = (p.longitude - centerLon) * cosLat * scale;
      final dy = -(p.latitude - centerLat) * scale; // flip y
      return Offset(size.width / 2 + dx, size.height / 2 + dy);
    }

    final path = Path()..moveTo(toCanvas(points.first).dx, toCanvas(points.first).dy);
    for (int i = 1; i < points.length; i++) {
      final p = toCanvas(points[i]);
      path.lineTo(p.dx, p.dy);
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
    canvas.drawPath(path, linePaint);

    // Start and end markers (filled circle + dark border).
    final start = toCanvas(points.first);
    final end = toCanvas(points.last);
    const dotR = 7.0;
    final fillStart = Paint()..color = startColor;
    final fillEnd = Paint()..color = endColor;
    final outline = Paint()
      ..color = const Color(0xFF0A0E14) // matches AppColors.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;
    canvas.drawCircle(start, dotR, fillStart);
    canvas.drawCircle(start, dotR, outline);
    canvas.drawCircle(end, dotR, fillEnd);
    canvas.drawCircle(end, dotR, outline);
  }

  @override
  bool shouldRepaint(covariant RoutePolylinePainter old) =>
      old.points != points ||
      old.lineColor != lineColor ||
      old.startColor != startColor ||
      old.endColor != endColor ||
      old.strokeWidth != strokeWidth ||
      old.padding != padding;
}
