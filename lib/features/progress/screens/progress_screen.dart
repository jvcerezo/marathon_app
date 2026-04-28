import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
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
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.huge,
        ),
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
          const SizedBox(height: AppSpacing.lg),
          runsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
            data: (runs) => Column(
              children: [
                _StreakCard(runs: runs),
                const SizedBox(height: AppSpacing.lg),
                _WeeklyMileageCard(runs: runs),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
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
    final cs = Theme.of(context).colorScheme;
    final currentMarathon = predictRaceTime(currentVdot, kMarathon);
    final targetMarathon = predictRaceTime(targetVdot, kMarathon);
    final delta = currentMarathon - targetMarathon;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Marathon prediction'),
          const SizedBox(height: AppSpacing.lg),
          HeroNumber(
            formatDuration(targetMarathon),
            size: 64,
            color: cs.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'After 12 months of consistency.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(Icons.timer_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today: ${formatDuration(currentMarathon)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const Spacer(),
                Text(
                  '−${formatDuration(delta)}',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final List<CompletedRun> runs;
  const _StreakCard({required this.runs});

  int _streak() {
    if (runs.isEmpty) return 0;
    final dayKeys = runs
        .map((r) => DateTime(
              r.startedAt.year,
              r.startedAt.month,
              r.startedAt.day,
            ))
        .toSet();
    int streak = 0;
    var day = DateTime.now();
    day = DateTime(day.year, day.month, day.day);
    while (true) {
      if (dayKeys.contains(day)) {
        streak++;
        day = day.subtract(const Duration(days: 1));
      } else {
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
    final cs = Theme.of(context).colorScheme;
    final streak = _streak();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Streak', color: AppColors.ember),
                const SizedBox(height: AppSpacing.md),
                HeroNumber(
                  '$streak',
                  unit: streak == 1 ? 'day' : 'days',
                  size: 56,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  "Rest days don't break it.",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(
            Icons.local_fire_department_rounded,
            color: AppColors.ember,
            size: 56,
          ),
        ],
      ),
    );
  }
}

class _WeeklyMileageCard extends StatelessWidget {
  final List<CompletedRun> runs;
  const _WeeklyMileageCard({required this.runs});

  Map<int, double> _byWeek() {
    final now = DateTime.now();
    final result = <int, double>{};
    for (final r in runs) {
      final daysAgo = now.difference(r.startedAt).inDays;
      final weeksAgo = daysAgo ~/ 7;
      if (weeksAgo > 11) continue;
      result[weeksAgo] = (result[weeksAgo] ?? 0) + r.distanceKm;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final data = _byWeek();
    final total = data.values.fold<double>(0, (a, b) => a + b);
    final maxV = data.values.fold<double>(0, (a, b) => b > a ? b : a);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Last 12 weeks'),
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              HeroNumber(
                total.toStringAsFixed(0),
                unit: 'km logged',
                size: 44,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: maxV == 0 ? 10 : maxV * 1.2,
                titlesData: const FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
                barGroups: List.generate(12, (i) {
                  final week = 11 - i;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[week] ?? 0,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                        color: cs.primary,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxV == 0 ? 10 : maxV * 1.2,
                          color: cs.surfaceContainerHigh,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final pct = (adherence * 100).round();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('Adherence'),
          const SizedBox(height: AppSpacing.md),
          HeroNumber(
            '$pct',
            unit: '%',
            size: 56,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  Expanded(
                    flex: hits == 0 ? 0 : hits,
                    child: Container(color: AppColors.pulse),
                  ),
                  Expanded(
                    flex: partial == 0 ? 0 : partial,
                    child: Container(color: AppColors.warn),
                  ),
                  Expanded(
                    flex: missed == 0 ? 0 : missed,
                    child: Container(color: AppColors.miss),
                  ),
                  if (hits + partial + missed == 0)
                    Expanded(
                      flex: 1,
                      child: Container(color: cs.surfaceContainerHigh),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: AppSpacing.lg,
            runSpacing: AppSpacing.sm,
            children: [
              _LegendDot(color: AppColors.pulse, label: '$hits hit'),
              _LegendDot(color: AppColors.warn, label: '$partial partial'),
              _LegendDot(color: AppColors.miss, label: '$missed missed'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
