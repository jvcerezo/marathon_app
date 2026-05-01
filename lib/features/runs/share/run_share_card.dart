import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/design/tokens.dart';
import '../../../core/format/format.dart';
import '../../../core/math/polyline.dart';
import '../models/completed_run.dart';
import 'route_polyline_painter.dart';

/// 9:16 share card rendered for the user's run. Designed to be screenshot-
/// ready for Instagram Stories or any vertical share format. The route
/// polyline is the visual hero, with stats arranged below.
///
/// Logical size is fixed at 360x640. Capture this widget at pixelRatio 3
/// to produce a 1080x1920 PNG.
class RunShareCard extends StatelessWidget {
  final CompletedRun run;

  /// Logical width of the card. Defaults to the design size; the share
  /// screen renders at this size and captures at 3x to get 1080x1920 px.
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

    return RepaintBoundary(
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F141C),
              Color(0xFF0A0E14),
            ],
          ),
        ),
        padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BrandMark(),
            const SizedBox(height: 6),
            Text(
              _dateLabel(run.startedAt),
              style: const TextStyle(
                color: AppColors.fog,
                fontSize: 11,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 18),
            const _Divider(),
            const SizedBox(height: 8),
            Expanded(
              child: points.length >= 2
                  ? CustomPaint(
                      size: Size.infinite,
                      painter: RoutePolylinePainter(
                        points: points,
                        lineColor: AppColors.pulse,
                        startColor: AppColors.pulse,
                        endColor: AppColors.ember,
                        strokeWidth: 4.5,
                        padding: 16,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No route',
                        style: TextStyle(color: AppColors.smoke, fontSize: 12),
                      ),
                    ),
            ),
            const SizedBox(height: 8),
            const _Divider(),
            const SizedBox(height: 18),
            // Hero distance
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: run.distanceKm.toStringAsFixed(2),
                    style: const TextStyle(
                      color: AppColors.bone,
                      fontSize: 64,
                      height: 1.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -2,
                    ),
                  ),
                  const TextSpan(
                    text: '  km',
                    style: TextStyle(
                      color: AppColors.fog,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // Stats row
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'Time',
                    value: formatDurationSec(run.movingTimeSec),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Pace',
                    value: formatPace(run.avgPaceSecPerKm)
                        .replaceAll('/km', ''),
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'Elev',
                    value: '${run.elevationGainM.toStringAsFixed(0)} m',
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'find your daloy.',
                style: TextStyle(
                  color: AppColors.mist,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _dateLabel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${shortDayName(d.weekday).toUpperCase()} '
        '${shortMonthName(d.month).toUpperCase()} ${d.day} · $h:$m';
  }
}

class _BrandMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'DALOY',
      style: TextStyle(
        color: AppColors.bone,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 6,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: AppColors.iron,
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: AppColors.fog,
            fontSize: 10,
            letterSpacing: 1.6,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.bone,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
