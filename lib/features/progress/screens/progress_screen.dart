import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/format/format.dart';
import '../../fitness/predictor.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../runs/models/completed_run.dart';
import '../../runs/providers/runs_providers.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final runsAsync = ref.watch(runsProvider);
    final planAsync = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (p) => p == null
                ? const SizedBox.shrink()
                : _PredictionCard(
                    targetVdot: estimateTargetVdot(p),
                    currentVdot: estimateCurrentVdot(p),
                  ),
          ),
          const SizedBox(height: 16),
          runsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('Error: $e'),
            data: (runs) => Column(
              children: [
                _StreakCard(runs: runs),
                const SizedBox(height: 16),
                _WeeklyMileageChart(runs: runs),
              ],
            ),
          ),
          const SizedBox(height: 16),
          planAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (plan) {
              if (plan == null) return const SizedBox.shrink();
              final hits = plan.sessions
                  .where((s) => s.status == SessionStatus.hit)
                  .length;
              final partial = plan.sessions
                  .where((s) => s.status == SessionStatus.partial)
                  .length;
              final missed = plan.sessions
                  .where((s) => s.status == SessionStatus.missed)
                  .length;
              final total = hits + partial + missed;
              final adherence = total == 0 ? 0.0 : hits / total;
              return _AdherenceCard(
                adherence: adherence,
                hits: hits,
                partial: partial,
                missed: missed,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final double targetVdot;
  final double currentVdot;
  const _PredictionCard({
    required this.targetVdot,
    required this.currentVdot,
  });

  @override
  Widget build(BuildContext context) {
    final currentMarathon = predictRaceTime(currentVdot, kMarathon);
    final targetMarathon = predictRaceTime(targetVdot, kMarathon);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marathon prediction',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PredictionStat(
                    label: 'Right now',
                    value: formatDuration(currentMarathon),
                  ),
                ),
                Expanded(
                  child: _PredictionStat(
                    label: 'After 12 months',
                    value: formatDuration(targetMarathon),
                    emphasized: true,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PredictionStat extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasized;
  const _PredictionStat({
    required this.label,
    required this.value,
    this.emphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: emphasized
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
        ),
      ],
    );
  }
}

class _StreakCard extends StatelessWidget {
  final List<CompletedRun> runs;
  const _StreakCard({required this.runs});

  int _streak(List<CompletedRun> runs) {
    if (runs.isEmpty) return 0;
    final dayKeys = runs
        .map((r) => DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day))
        .toSet();
    int streak = 0;
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    while (true) {
      if (dayKeys.contains(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
        // Allow rest days: only break if we've gone 2 days without a run.
        final yesterday = day.subtract(const Duration(days: 1));
        if (dayKeys.contains(yesterday)) {
          day = yesterday;
        } else {
          break;
        }
      }
      if (streak > 365) break;
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.local_fire_department_outlined,
              color: Theme.of(context).colorScheme.primary,
              size: 36,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_streak(runs)} day streak',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                Text(
                  'Rest days don\'t break it.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyMileageChart extends StatelessWidget {
  final List<CompletedRun> runs;
  const _WeeklyMileageChart({required this.runs});

  Map<int, double> _byWeek() {
    final now = DateTime.now();
    final result = <int, double>{};
    for (final r in runs) {
      final daysAgo = now.difference(r.startedAt).inDays;
      final weeksAgo = daysAgo ~/ 7;
      if (weeksAgo > 12) continue;
      result[weeksAgo] = (result[weeksAgo] ?? 0) + r.distanceKm;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final data = _byWeek();
    final spots = <FlSpot>[];
    for (int week = 12; week >= 0; week--) {
      spots.add(FlSpot((12 - week).toDouble(), data[week] ?? 0));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly mileage',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Last 12 weeks',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  barGroups: spots
                      .map(
                        (s) => BarChartGroupData(
                          x: s.x.toInt(),
                          barRods: [
                            BarChartRodData(
                              toY: s.y,
                              width: 12,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  final double adherence;
  final int hits;
  final int partial;
  final int missed;
  const _AdherenceCard({
    required this.adherence,
    required this.hits,
    required this.partial,
    required this.missed,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (adherence * 100).round();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plan adherence',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: adherence,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Text('$pct% of completed sessions hit'),
            const SizedBox(height: 4),
            Text(
              '$hits hit · $partial partial · $missed missed',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
