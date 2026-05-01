import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/branding/daloy_logo.dart';
import '../../../core/branding/daloy_wordmark.dart';
import '../../../core/math/polyline.dart';
import '../models/completed_run.dart';
import 'route_polyline_painter.dart';

/// Transparent share overlay rendered for the user's run. Designed to
/// be dropped on top of the user's own photo or video in Instagram
/// Stories. The card itself is transparent — only the text, polyline,
/// and brand mark are drawn.
///
/// [color] tints every visible element (stat labels, stat values,
/// polyline, logo, wordmark). The compose screen pipes a user-picked
/// color in here so the overlay can adapt to the photo behind it
/// (white on a dark photo, black on a bright photo, etc.).
///
/// Logical size is 360x640. Capture at pixelRatio 3 to produce a
/// 1080x1920 PNG with alpha.
class RunShareCard extends StatelessWidget {
  final CompletedRun run;
  final double width;
  final Color color;

  const RunShareCard({
    super.key,
    required this.run,
    this.width = 360,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final height = width * 16 / 9;
    final points = run.encodedPolyline == null
        ? const <LatLng>[]
        : decodePolyline(run.encodedPolyline!)
            .map((p) => LatLng(p.lat, p.lon))
            .toList(growable: false);

    return SizedBox(
      width: width,
      height: height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 80, 24, 64),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _StatBlock(
              label: 'Distance',
              value: _distanceText(run.distanceKm),
              color: color,
            ),
            const SizedBox(height: 28),
            _StatBlock(
              label: 'Pace',
              value: _paceText(run.avgPaceSecPerKm),
              color: color,
            ),
            const SizedBox(height: 28),
            _StatBlock(
              label: 'Time',
              value: _timeText(run.movingTimeSec),
              color: color,
            ),
            const SizedBox(height: 36),
            Expanded(
              child: points.length >= 2
                  ? CustomPaint(
                      size: Size.infinite,
                      painter: RoutePolylinePainter(
                        points: points,
                        lineColor: color,
                        startColor: color,
                        endColor: color,
                        strokeWidth: 5,
                        padding: 0,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DaloyLogo(size: 18, color: color),
                const SizedBox(width: 8),
                DaloyWordmark(height: 22, color: color),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _distanceText(double km) => '${km.toStringAsFixed(2)} km';

  static String _paceText(double? secPerKm) {
    if (secPerKm == null || secPerKm <= 0) return '--:--/km';
    final m = (secPerKm ~/ 60).toString();
    final s = (secPerKm.round() % 60).toString().padLeft(2, '0');
    return '$m:$s/km';
  }

  static String _timeText(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m}m';
    }
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
}

class _StatBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatBlock({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            shadows: _kTextShadow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 38,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            shadows: _kTextShadow,
          ),
        ),
      ],
    );
  }
}

/// Soft contrast halo behind text. Functional, not decorative — without
/// it the foreground (whatever color the user picked) can vanish against
/// busy photo backgrounds when the overlay is dropped on a photo.
const List<Shadow> _kTextShadow = [
  Shadow(
    color: Color(0x80000000),
    blurRadius: 8,
    offset: Offset(0, 1),
  ),
];
