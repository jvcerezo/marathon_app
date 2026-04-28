import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/polyline_thumb.dart';
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
          final summary = _summarize(runs);
          final grouped = _group(runs);
          final keys = grouped.keys.toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.fabSafe,
            ),
            children: [
              _Summary(summary: summary),
              const SizedBox(height: AppSpacing.lg),
              for (final key in keys) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs, AppSpacing.md, 0, AppSpacing.sm,
                  ),
                  child: SectionLabel(key),
                ),
                ...grouped[key]!.map(
                  (r) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _RunRow(
                      run: r,
                      onTap: () => context.push('/runs/${r.id}'),
                    ),
                  ),
                ),
              ],
            ],
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

  _RunsSummary _summarize(List<CompletedRun> runs) {
    final total = runs.fold<double>(0, (a, r) => a + r.distanceKm);
    final time =
        runs.fold<int>(0, (a, r) => a + r.movingTimeSec);
    return _RunsSummary(
      totalKm: total,
      totalSeconds: time,
      count: runs.length,
    );
  }
}

class _RunsSummary {
  final double totalKm;
  final int totalSeconds;
  final int count;
  const _RunsSummary({
    required this.totalKm,
    required this.totalSeconds,
    required this.count,
  });
}

class _Summary extends StatelessWidget {
  final _RunsSummary summary;
  const _Summary({required this.summary});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'Runs',
              value: '${summary.count}',
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: cs.outlineVariant,
          ),
          Expanded(
            child: _SummaryStat(
              label: 'Distance',
              value: summary.totalKm.toStringAsFixed(0),
              unit: 'km',
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: cs.outlineVariant,
          ),
          Expanded(
            child: _SummaryStat(
              label: 'Time',
              value: _hmm(summary.totalSeconds),
            ),
          ),
        ],
      ),
    );
  }

  String _hmm(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  const _SummaryStat({
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        SectionLabel(label),
        const SizedBox(height: AppSpacing.xs),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              color: cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            text: value,
            children: unit == null
                ? null
                : [
                    TextSpan(
                      text: ' ${unit!}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
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
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              PolylineThumb(
                encodedPolyline: run.encodedPolyline,
                color: cs.primary,
                background: cs.surfaceContainerHigh,
                size: 64,
                radius: AppRadius.md,
              ),
              const SizedBox(width: AppSpacing.md),
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
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'km',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        if (run.matchedSessionId != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.pulse.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check,
                                    size: 12, color: AppColors.pulse),
                                SizedBox(width: 2),
                                Text(
                                  'PLAN',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                    color: AppColors.pulse,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDurationSec(run.movingTimeSec)} · ${formatPace(run.avgPaceSecPerKm)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _timeLabel(run.startedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeLabel(DateTime d) {
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
            Text('No runs yet',
                style: Theme.of(context).textTheme.headlineSmall),
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
