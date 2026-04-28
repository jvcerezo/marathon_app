import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../models/completed_run.dart';
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
        error: (e, _) => Center(child: Text('$e')),
        data: (runs) {
          if (runs.isEmpty) return const _EmptyState();
          final grouped = _group(runs);
          final keys = grouped.keys.toList();
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge,
            ),
            itemCount: keys.length,
            itemBuilder: (context, i) {
              final key = keys[i];
              final group = grouped[key]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xs, AppSpacing.lg, 0, AppSpacing.md,
                    ),
                    child: SectionLabel(key),
                  ),
                  ...group.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _RunRow(
                          run: r,
                          onTap: () => context.push('/runs/${r.id}'),
                        ),
                      )),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<CompletedRun>> _group(List<CompletedRun> runs) {
    final out = <String, List<CompletedRun>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final r in runs) {
      final d = DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day);
      final daysAgo = today.difference(d).inDays;
      final key = daysAgo == 0
          ? 'TODAY'
          : daysAgo == 1
              ? 'YESTERDAY'
              : daysAgo < 7
                  ? 'EARLIER THIS WEEK'
                  : daysAgo < 30
                      ? 'THIS MONTH'
                      : '${shortMonthName(r.startedAt.month).toUpperCase()} ${r.startedAt.year}';
      out.putIfAbsent(key, () => []).add(r);
    }
    return out;
  }
}

class _RunRow extends StatelessWidget {
  final CompletedRun run;
  final VoidCallback onTap;

  const _RunRow({required this.run, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          run.distanceKm.toStringAsFixed(2),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDurationSec(run.movingTimeSec)} · ${formatPace(run.avgPaceSecPerKm)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_run_outlined,
                size: 56, color: cs.onSurfaceVariant),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No runs yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tap Today to start your first one.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
