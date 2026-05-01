import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/branding/daloy_logo.dart';
import '../../../core/design/tokens.dart';
import '../../../core/math/polyline.dart';
import '../models/completed_run.dart';
import 'route_polyline_painter.dart';

/// Transparent share overlay rendered for the user's run. Designed to
/// be dropped on top of the user's own photo or video in Instagram
/// Stories. The card itself is transparent — only the text, polyline,
/// and brand mark are drawn. White typography is used so it stays
/// legible on most photo backgrounds.
///
/// Logical size is 360x640. Capture at pixelRatio 3 to produce a
/// 1080x1920 PNG with alpha.
class RunShareCard extends StatelessWidget {
  final CompletedRun run;

  /// Logical width of the card. The share screen renders at this size
  /// and captures at 3x to produce 1080x1920 px.
  final double width;

  const RunShareCard({
    super.key,
    required this.run,
    this.width = 360,
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
            _StatBlock(label: 'Distance', value: _distanceText(run.distanceKm)),
            const SizedBox(height: 28),
            _StatBlock(label: 'Pace', value: _paceText(run.avgPaceSecPerKm)),
            const SizedBox(height: 28),
            _StatBlock(label: 'Time', value: _timeText(run.movingTimeSec)),
            const SizedBox(height: 36),
            Expanded(
              child: points.length >= 2
                  ? CustomPaint(
                      size: Size.infinite,
                      painter: RoutePolylinePainter(
                        points: points,
                        lineColor: AppColors.pulse,
                        startColor: AppColors.pulse,
                        endColor: AppColors.pulse,
                        strokeWidth: 5,
                        padding: 0,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            const DaloyLogo(
              size: 56,
              color: Colors.white,
              withPlate: false,
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
  const _StatBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.4,
            shadows: _kTextShadow,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
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

/// Subtle dark halo behind text. Functional, not decorative — without it
/// the white type vanishes against bright sky / pavement / shirt
/// backgrounds when the overlay is dropped on a photo.
const List<Shadow> _kTextShadow = [
  Shadow(
    color: Color(0x80000000),
    blurRadius: 8,
    offset: Offset(0, 1),
  ),
];
