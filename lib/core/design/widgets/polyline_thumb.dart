import 'dart:math';

import 'package:flutter/material.dart';

import '../../math/polyline.dart';

/// Compact, static thumbnail of a run polyline. No tiles, no map — just the
/// route shape. Auto-fits the encoded polyline into the given size.
class PolylineThumb extends StatelessWidget {
  final String? encodedPolyline;
  final double size;
  final double strokeWidth;
  final Color color;
  final Color background;
  final double radius;

  const PolylineThumb({
    super.key,
    required this.encodedPolyline,
    required this.color,
    required this.background,
    this.size = 64,
    this.strokeWidth = 2.5,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final points = encodedPolyline == null || encodedPolyline!.isEmpty
        ? const <({double lat, double lon})>[]
        : decodePolyline(encodedPolyline!);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(radius),
      ),
      clipBehavior: Clip.antiAlias,
      child: points.length < 2
          ? Center(
              child: Icon(
                Icons.timeline_rounded,
                color: color.withValues(alpha: 0.4),
                size: size * 0.35,
              ),
            )
          : CustomPaint(
              size: Size.square(size),
              painter: _PolylinePainter(
                points: points,
                color: color,
                strokeWidth: strokeWidth,
              ),
            ),
    );
  }
}

class _PolylinePainter extends CustomPainter {
  final List<({double lat, double lon})> points;
  final Color color;
  final double strokeWidth;

  _PolylinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minLat = double.infinity;
    double maxLat = -double.infinity;
    double minLon = double.infinity;
    double maxLon = -double.infinity;
    for (final p in points) {
      minLat = min(minLat, p.lat);
      maxLat = max(maxLat, p.lat);
      minLon = min(minLon, p.lon);
      maxLon = max(maxLon, p.lon);
    }

    final padding = strokeWidth * 1.5;
    final w = size.width - padding * 2;
    final h = size.height - padding * 2;

    final dLat = max(maxLat - minLat, 1e-9);
    final dLon = max(maxLon - minLon, 1e-9);

    // Use the larger range as the controlling axis to preserve aspect.
    final scale = min(w / dLon, h / dLat);
    final drawnW = dLon * scale;
    final drawnH = dLat * scale;
    final offsetX = padding + (w - drawnW) / 2;
    final offsetY = padding + (h - drawnH) / 2;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = offsetX + (p.lon - minLon) * scale;
      // Latitude inverts: higher lat = north = top of canvas.
      final y = offsetY + (maxLat - p.lat) * scale;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PolylinePainter old) =>
      old.points != points ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
