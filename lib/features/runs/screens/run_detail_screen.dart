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
import '../../../core/math/polyline.dart';
import '../../../core/network/cached_tile_provider.dart';
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
                                    TileLayer(
                                      urlTemplate:
                                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName:
                                          'com.jvcerezo.bakas',
                                      tileProvider: CachedTileProvider(),
                                    ),
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
