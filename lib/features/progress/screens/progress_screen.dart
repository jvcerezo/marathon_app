import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/view_mode_selector.dart';
import '../../../core/format/format.dart';
import '../../fitness/predictor.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/providers/profile_providers.dart';
import '../../runs/models/completed_run.dart';
import '../../runs/providers/runs_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  ViewMode _mode = ViewMode.week;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final runsAsync = ref.watch(runsProvider);
    final planAsync = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.fabSafe,
        ),
        children: [
          const SizedBox(height: AppSpacing.sm),
          ViewModeSelector(
            value: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: AppSpacing.lg),
          runsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => Text('$e'),
            data: (runs) => switch (_mode) {
              ViewMode.day => _DaySummary(runs: runs),
              ViewMode.week => _WeekSummary(runs: runs),
              ViewMode.month => _MonthSummary(runs: runs),
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          profileAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (p) => p == null
                ? const SizedBox.shrink()
                : _PredictionCard(
                    targetVdot: estimateTargetVdot(p),
                    currentVdot: estimateCurrentVdot(p),
                    goalLabel: p.goalDistance.label,
                    goalMeters: p.goalDistance.meters,
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _PersonalRecordsCard(),
          const SizedBox(height: AppSpacing.lg),
          runsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (e, _) => const SizedBox.shrink(),
            data: (runs) => _StreakCard(runs: runs),
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

// =================== TIMEFRAME SUMMARIES ===================

class _DaySummary extends StatelessWidget {
  final List<CompletedRun> runs;
  const _DaySummary({required this.runs});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayRuns = runs
        .where((r) =>
            r.startedAt.year == today.year &&
            r.startedAt.month == today.month &&
            r.startedAt.day == today.day)
        .toList();
    final km = todayRuns.fold<double>(0, (a, r) => a + r.distanceKm);
    final timeSec =
        todayRuns.fold<int>(0, (a, r) => a + r.movingTimeSec);
    final avgPace = km > 0 ? timeSec / km : null;

    return _SummaryHero(
      eyebrow: 'TODAY',
      title:
          '${shortDayName(today.weekday)}, ${monthDay(today)}',
      kmValue: km.toStringAsFixed(2),
      runs: todayRuns.length,
      timeSec: timeSec,
      paceSecPerKm: avgPace,
      icon: PhosphorIconsDuotone.sun,
    );
  }
}

class _WeekSummary extends StatelessWidget {
  final List<CompletedRun> runs;
  const _WeekSummary({required this.runs});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(
        Duration(days: (today.weekday - DateTime.monday) % 7));
    final nextMonday = monday.add(const Duration(days: 7));
    final weekRuns = runs
        .where((r) =>
            !r.startedAt.isBefore(monday) && r.startedAt.isBefore(nextMonday))
        .toList();
    final km = weekRuns.fold<double>(0, (a, r) => a + r.distanceKm);
    final timeSec = weekRuns.fold<int>(0, (a, r) => a + r.movingTimeSec);
    final avgPace = km > 0 ? timeSec / km : null;

    final kmByDay = List<double>.filled(7, 0);
    for (final r in weekRuns) {
      final i = (r.startedAt.difference(monday).inDays).clamp(0, 6);
      kmByDay[i] += r.distanceKm;
    }

    return Column(
      children: [
        _SummaryHero(
          eyebrow: 'THIS WEEK',
          title: '${monthDay(monday)} – ${monthDay(nextMonday.subtract(const Duration(days: 1)))}',
          kmValue: km.toStringAsFixed(1),
          runs: weekRuns.length,
          timeSec: timeSec,
          paceSecPerKm: avgPace,
          icon: PhosphorIconsDuotone.calendar,
        ),
        const SizedBox(height: AppSpacing.lg),
        _DailyChart(
          values: kmByDay,
          labels: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
          title: 'Daily breakdown',
        ),
      ],
    );
  }
}

class _MonthSummary extends StatelessWidget {
  final List<CompletedRun> runs;
  const _MonthSummary({required this.runs});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    final monthRuns = runs
        .where((r) =>
            !r.startedAt.isBefore(monthStart) &&
            r.startedAt.isBefore(nextMonth))
        .toList();
    final km = monthRuns.fold<double>(0, (a, r) => a + r.distanceKm);
    final timeSec = monthRuns.fold<int>(0, (a, r) => a + r.movingTimeSec);
    final avgPace = km > 0 ? timeSec / km : null;

    // bucket km per ISO week of the month
    final perWeek = <int, double>{};
    for (final r in monthRuns) {
      final daysFromStart = r.startedAt.difference(monthStart).inDays;
      final weekIdx = daysFromStart ~/ 7;
      perWeek[weekIdx] = (perWeek[weekIdx] ?? 0) + r.distanceKm;
    }
    final values = List<double>.generate(5, (i) => perWeek[i] ?? 0);

    return Column(
      children: [
        _SummaryHero(
          eyebrow: 'THIS MONTH',
          title: '${_monthName(now.month)} ${now.year}',
          kmValue: km.toStringAsFixed(0),
          runs: monthRuns.length,
          timeSec: timeSec,
          paceSecPerKm: avgPace,
          icon: PhosphorIconsDuotone.calendarBlank,
        ),
        const SizedBox(height: AppSpacing.lg),
        _DailyChart(
          values: values,
          labels: const ['Wk 1', 'Wk 2', 'Wk 3', 'Wk 4', 'Wk 5'],
          title: 'Weekly breakdown',
        ),
      ],
    );
  }

  String _monthName(int m) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ][m - 1];
}

class _SummaryHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String kmValue;
  final int runs;
  final int timeSec;
  final double? paceSecPerKm;
  final IconData icon;

  const _SummaryHero({
    required this.eyebrow,
    required this.title,
    required this.kmValue,
    required this.runs,
    required this.timeSec,
    required this.paceSecPerKm,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.primary.withValues(alpha: 0.18),
            cs.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: cs.primary, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(eyebrow, color: cs.primary),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          HeroNumber(kmValue, unit: 'km', size: 56),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SubStat(
                  icon: PhosphorIconsRegular.flag,
                  label: 'Runs',
                  value: '$runs',
                ),
              ),
              Expanded(
                child: _SubStat(
                  icon: PhosphorIconsRegular.timer,
                  label: 'Time',
                  value: _hmm(timeSec),
                ),
              ),
              Expanded(
                child: _SubStat(
                  icon: PhosphorIconsRegular.gauge,
                  label: 'Avg pace',
                  value: paceSecPerKm == null
                      ? '–'
                      : formatPace(paceSecPerKm).replaceAll('/km', ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _hmm(int seconds) {
    if (seconds == 0) return '–';
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h == 0) return '${m}m';
    return '${h}h${m.toString().padLeft(2, '0')}';
  }
}

class _SubStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SubStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: cs.onSurfaceVariant),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

class _DailyChart extends StatelessWidget {
  final List<double> values;
  final List<String> labels;
  final String title;
  const _DailyChart({
    required this.values,
    required this.labels,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxV = values.fold<double>(0, (a, b) => b > a ? b : a);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(title),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                maxY: maxV == 0 ? 10 : maxV * 1.25,
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            labels[i],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(values.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: values[i],
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: values[i] > 0
                            ? cs.primary
                            : cs.outlineVariant,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxV == 0 ? 10 : maxV * 1.25,
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

// =================== TIMEFRAME-AGNOSTIC CARDS ===================

class _PredictionCard extends StatelessWidget {
  final double targetVdot;
  final double currentVdot;
  final String goalLabel;
  final double goalMeters;
  const _PredictionCard({
    required this.targetVdot,
    required this.currentVdot,
    required this.goalLabel,
    required this.goalMeters,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentMarathon = predictRaceTime(currentVdot, goalMeters);
    final targetMarathon = predictRaceTime(targetVdot, goalMeters);
    final delta = currentMarathon - targetMarathon;

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
          Row(
            children: [
              Icon(PhosphorIconsDuotone.medal, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              SectionLabel('$goalLabel prediction'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HeroNumber(
            formatDuration(targetMarathon),
            size: 56,
            color: cs.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'After 12 months of consistency.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                Icon(PhosphorIconsRegular.timer,
                    size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Today: ${formatDuration(currentMarathon)}',
                  style: const TextStyle(
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
    for (int i = 0; i < 365; i++) {
      if (dayKeys.contains(day)) {
        streak++;
      } else {
        final yesterday = day.subtract(const Duration(days: 1));
        if (!dayKeys.contains(yesterday)) break;
      }
      day = day.subtract(const Duration(days: 1));
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.ember.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIconsDuotone.fire,
              color: AppColors.ember,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Streak', color: AppColors.ember),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                    text: '$streak',
                    children: [
                      TextSpan(
                        text: streak == 1 ? ' day' : ' days',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
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
          Row(
            children: [
              Icon(PhosphorIconsDuotone.target,
                  color: cs.primary, size: 20),
              const SizedBox(width: 8),
              SectionLabel('Plan adherence'),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          HeroNumber('$pct', unit: '%', size: 48),
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

/// Personal records card. Shows the fastest contiguous split for each
/// milestone distance in the user's full run history. Hides itself if
/// no runs have qualifying splits yet (e.g. for a brand-new user).
class _PersonalRecordsCard extends ConsumerWidget {
  const _PersonalRecordsCard();

  static const List<({int distanceM, String label})> _milestones = [
    (distanceM: 1000, label: '1K'),
    (distanceM: 5000, label: '5K'),
    (distanceM: 10000, label: '10K'),
    (distanceM: 21098, label: 'Half'),
    (distanceM: 42195, label: 'Marathon'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prsAsync = ref.watch(personalRecordsProvider);
    return prsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (prs) {
        if (prs.isEmpty) return const SizedBox.shrink();
        final cs = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(PhosphorIconsDuotone.medal, color: cs.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Personal records',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              for (final m in _milestones)
                if (prs[m.distanceM] != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: Text(
                            m.label,
                            style: TextStyle(
                              color: cs.onSurfaceVariant,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        Text(
                          _formatSplit(prs[m.distanceM]!.timeSec),
                          style: TextStyle(
                            color: cs.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        );
      },
    );
  }

  static String _formatSplit(double seconds) {
    final s = seconds.round();
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}
