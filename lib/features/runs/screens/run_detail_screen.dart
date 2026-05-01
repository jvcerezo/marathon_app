import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/stat_tile.dart';
import '../../../core/format/format.dart';
import '../../../core/math/geo_math.dart';
import '../../../core/math/polyline.dart';
import '../../../core/network/map_tiles.dart';
import '../../recording/models/run_sample.dart';
import '../providers/runs_providers.dart';

class RunDetailScreen extends ConsumerWidget {
  final String runId;
  const RunDetailScreen({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(runDetailProvider(runId));
    final cs = Theme.of(context).colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: cs.surface,
        body: runAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (run) {
            if (run == null) return const Center(child: Text('Run not found.'));
            final points = run.encodedPolyline == null
                ? <LatLng>[]
                : decodePolyline(run.encodedPolyline!)
                    .map((p) => LatLng(p.lat, p.lon))
                    .toList();
            final hasMap = points.length >= 2;

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: hasMap ? 320 : 100,
                  pinned: true,
                  backgroundColor: cs.surface,
                  elevation: 0,
                  iconTheme: IconThemeData(color: cs.onSurface),
                  flexibleSpace: hasMap
                      ? FlexibleSpaceBar(
                          background: Stack(
                            children: [
                              // Dark backdrop so unloaded tiles never flash white.
                              Positioned.fill(
                                child: Container(color: AppColors.shade),
                              ),
                              Positioned.fill(
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCameraFit: CameraFit.bounds(
                                      bounds: LatLngBounds.fromPoints(points),
                                      padding: const EdgeInsets.all(40),
                                    ),
                                    backgroundColor: AppColors.shade,
                                    interactionOptions: const InteractionOptions(
                                      flags: InteractiveFlag.pinchZoom |
                                          InteractiveFlag.drag,
                                    ),
                                  ),
                                  children: [
                                    MapTiles.baseLayer(),
                                    PolylineLayer(
                                      polylines: [
                                        Polyline(
                                          points: points,
                                          strokeWidth: 6,
                                          color: AppColors.pulse,
                                          borderColor: AppColors.ink,
                                          borderStrokeWidth: 2,
                                        ),
                                      ],
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: points.first,
                                          width: 22,
                                          height: 22,
                                          child: const _StartMarker(),
                                        ),
                                        Marker(
                                          point: points.last,
                                          width: 22,
                                          height: 22,
                                          child: const _EndMarker(),
                                        ),
                                      ],
                                    ),
                                    MapTiles.attribution(),
                                  ],
                                ),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                height: 56,
                                child: IgnorePointer(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          cs.surface.withValues(alpha: 0),
                                          cs.surface,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : null,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.huge),
                  sliver: SliverList.list(
                    children: [
                      SectionLabel(_dateLabel(run.startedAt)),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          HeroNumber(
                            run.distanceKm.toStringAsFixed(2),
                            unit: 'km',
                            size: 80,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        child: StatRow(
                          tiles: [
                            StatTile(
                              label: 'Time',
                              value: formatDurationSec(run.movingTimeSec),
                            ),
                            StatTile(
                              label: 'Pace',
                              value: formatPace(run.avgPaceSecPerKm)
                                  .replaceAll('/km', ''),
                            ),
                            StatTile(
                              label: 'Elev',
                              value: run.elevationGainM.toStringAsFixed(0),
                              unit: 'm',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _ElevationSection(runId: runId),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final hour = d.hour.toString().padLeft(2, '0');
    final minute = d.minute.toString().padLeft(2, '0');
    return '${shortDayName(d.weekday)} ${monthDay(d)}, $hour:$minute';
  }
}

class _StartMarker extends StatelessWidget {
  const _StartMarker();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.pulse,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 3),
      ),
    );
  }
}

class _EndMarker extends StatelessWidget {
  const _EndMarker();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ember,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.ink, width: 3),
      ),
    );
  }
}

/// Elevation-over-distance line chart for the run. Quietly hides itself
/// when the run has no usable elevation data — most often because the
/// device's GNSS chip didn't report altitude or the run was too short
/// to draw a meaningful profile.
class _ElevationSection extends ConsumerWidget {
  final String runId;
  const _ElevationSection({required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final samplesAsync = ref.watch(runSamplesProvider(runId));
    return samplesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (samples) {
        final profile = _buildElevationProfile(samples);
        if (profile == null) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Elevation'),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: SizedBox(
                height: 140,
                child: _ElevationChart(profile: profile),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ElevationProfile {
  final List<FlSpot> spots;
  final double minEl;
  final double maxEl;
  final double maxDistKm;
  const _ElevationProfile({
    required this.spots,
    required this.minEl,
    required this.maxEl,
    required this.maxDistKm,
  });
}

_ElevationProfile? _buildElevationProfile(List<RunSample> samples) {
  if (samples.length < 4) return null;
  final spots = <FlSpot>[];
  double cumDist = 0;
  RunSample? prev;
  double minEl = double.infinity;
  double maxEl = -double.infinity;
  for (final s in samples) {
    if (prev != null) {
      cumDist +=
          haversineMeters(prev.lat, prev.lon, s.lat, s.lon);
    }
    final el = s.elevation;
    if (el != null) {
      spots.add(FlSpot(cumDist / 1000.0, el));
      if (el < minEl) minEl = el;
      if (el > maxEl) maxEl = el;
    }
    prev = s;
  }
  if (spots.length < 4) return null;
  if (maxEl - minEl < 1.0) return null; // Flat enough that there's nothing to show.
  return _ElevationProfile(
    spots: spots,
    minEl: minEl,
    maxEl: maxEl,
    maxDistKm: cumDist / 1000.0,
  );
}

class _ElevationChart extends StatelessWidget {
  final _ElevationProfile profile;
  const _ElevationChart({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final padBottom = (profile.maxEl - profile.minEl) * 0.1;
    return LineChart(
      LineChartData(
        minX: 0,
        maxX: profile.maxDistKm,
        minY: profile.minEl - padBottom,
        maxY: profile.maxEl + padBottom,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: ((profile.maxEl - profile.minEl) / 2)
                  .clamp(1.0, double.infinity),
              getTitlesWidget: (value, meta) => Text(
                '${value.round()}',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: (profile.maxDistKm / 4).clamp(0.1, double.infinity),
              getTitlesWidget: (value, meta) => Text(
                value.toStringAsFixed(value < 10 ? 1 : 0),
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: profile.spots,
            isCurved: true,
            curveSmoothness: 0.18,
            barWidth: 2,
            color: AppColors.pulse,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.pulse.withValues(alpha: 0.18),
            ),
          ),
        ],
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
