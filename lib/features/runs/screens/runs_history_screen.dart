import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/format.dart';
import '../providers/runs_providers.dart';

class RunsHistoryScreen extends ConsumerWidget {
  const RunsHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(runsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Runs')),
      body: runsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (runs) {
          if (runs.isEmpty) {
            return const Center(
              child: Text('No runs yet. Tap Today to start your first one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: runs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final r = runs[i];
              return Card(
                child: ListTile(
                  onTap: () => context.push('/runs/${r.id}'),
                  title: Text(
                    formatDistanceKm(r.distanceKm, decimals: 2),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  subtitle: Text(
                    '${formatDurationSec(r.movingTimeSec)} · '
                    '${formatPace(r.avgPaceSecPerKm)} · '
                    '${_dateLabel(r.startedAt)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _dateLabel(DateTime d) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(d.year, d.month, d.day);
    final daysAgo = today.difference(start).inDays;
    if (daysAgo == 0) return 'Today';
    if (daysAgo == 1) return 'Yesterday';
    if (daysAgo < 7) return '$daysAgo days ago';
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
