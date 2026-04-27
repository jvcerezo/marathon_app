import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/format/format.dart';
import '../../../core/math/polyline.dart';
import '../providers/runs_providers.dart';

class RunDetailScreen extends ConsumerWidget {
  final String runId;
  const RunDetailScreen({super.key, required this.runId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAsync = ref.watch(runDetailProvider(runId));
    return Scaffold(
      appBar: AppBar(title: const Text('Run')),
      body: runAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (run) {
          if (run == null) return const Center(child: Text('Run not found.'));
          final points = run.encodedPolyline == null
              ? <LatLng>[]
              : decodePolyline(run.encodedPolyline!)
                  .map((p) => LatLng(p.lat, p.lon))
                  .toList();
          final hasMap = points.length >= 2;

          return ListView(
            children: [
              if (hasMap)
                SizedBox(
                  height: 280,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCameraFit: CameraFit.bounds(
                        bounds: LatLngBounds.fromPoints(points),
                        padding: const EdgeInsets.all(32),
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.jvcerezo.marathon_app',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: points,
                            strokeWidth: 4,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateLabel(run.startedAt),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatDistanceKm(run.distanceKm),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _Stat(
                            label: 'Duration',
                            value: formatDurationSec(run.movingTimeSec),
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            label: 'Avg pace',
                            value: formatPace(run.avgPaceSecPerKm),
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            label: 'Elevation',
                            value: '${run.elevationGainM.toStringAsFixed(0)} m',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _dateLabel(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
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
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
