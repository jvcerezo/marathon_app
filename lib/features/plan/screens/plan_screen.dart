import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../models/plan_session.dart';
import '../providers/plan_providers.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  int? _selectedWeek;
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final planAsync = ref.watch(activePlanProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Plan')),
      body: planAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No plan yet.'));
          }
          final byWeek = <int, List<PlanSession>>{};
          for (final s in plan.sessions) {
            byWeek.putIfAbsent(s.weekNumber, () => []).add(s);
          }
          final weeks = byWeek.keys.toList()..sort();

          final today = DateTime.now();
          final currentWeek = weeks.firstWhere(
            (w) {
              final ws = byWeek[w]!;
              final start = ws.first.scheduledDate;
              final end = start.add(const Duration(days: 7));
              return today.isAfter(start.subtract(const Duration(days: 1))) &&
                  today.isBefore(end);
            },
            orElse: () => weeks.first,
          );
          final selectedWeek = _selectedWeek ?? currentWeek;
          final selectedSessions = byWeek[selectedWeek] ?? [];
          final phase = _phaseFor(selectedWeek);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              0, AppSpacing.sm, 0, AppSpacing.huge,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _PlanHeader(
                  selectedWeek: selectedWeek,
                  phase: phase,
                  totalWeeks: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _PhaseStrip(currentWeek: selectedWeek),
              ),
              const SizedBox(height: AppSpacing.lg),
              _WeekScroller(
                controller: _scrollController,
                weeks: weeks,
                byWeek: byWeek,
                selectedWeek: selectedWeek,
                currentWeek: currentWeek,
                onTap: (w) => setState(() => _selectedWeek = w),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _WeekDetail(
                  weekNumber: selectedWeek,
                  sessions: selectedSessions,
                  isCurrent: selectedWeek == currentWeek,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _phaseFor(int week) {
    if (week <= 12) return 'Foundation';
    if (week <= 24) return 'Base';
    if (week <= 36) return 'Build';
    if (week <= 48) return 'Peak';
    return 'Taper';
  }
}

class _PlanHeader extends StatelessWidget {
  final int selectedWeek;
  final String phase;
  final int totalWeeks;
  const _PlanHeader({
    required this.selectedWeek,
    required this.phase,
    required this.totalWeeks,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(phase),
              const SizedBox(height: AppSpacing.xs),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.6,
                    color: cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  text: 'Week $selectedWeek',
                  children: [
                    TextSpan(
                      text: ' of $totalWeeks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    );
  }
}

class _PhaseStrip extends StatelessWidget {
  final int currentWeek;
  const _PhaseStrip({required this.currentWeek});

  static const _phases = [
    (label: 'Foundation', start: 1, end: 12),
    (label: 'Base', start: 13, end: 24),
    (label: 'Build', start: 25, end: 36),
    (label: 'Peak', start: 37, end: 48),
    (label: 'Taper', start: 49, end: 52),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: _phases.map((p) {
        final isActive = currentWeek >= p.start && currentWeek <= p.end;
        final weeks = p.end - p.start + 1;
        return Expanded(
          flex: weeks,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive ? cs.primary : cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  p.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isActive ? FontWeight.w800 : FontWeight.w600,
                    color: isActive ? cs.primary : cs.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _WeekScroller extends StatelessWidget {
  final ScrollController controller;
  final List<int> weeks;
  final Map<int, List<PlanSession>> byWeek;
  final int selectedWeek;
  final int currentWeek;
  final ValueChanged<int> onTap;

  const _WeekScroller({
    required this.controller,
    required this.weeks,
    required this.byWeek,
    required this.selectedWeek,
    required this.currentWeek,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: weeks.length,
        itemBuilder: (context, i) {
          final w = weeks[i];
          final ss = byWeek[w]!;
          final totalKm = ss.fold<double>(
              0, (sum, s) => sum + s.prescribedDistanceKm);
          final hits =
              ss.where((s) => s.status == SessionStatus.hit).length;
          final running = ss
              .where((s) =>
                  s.type != SessionType.rest && s.type != SessionType.race)
              .length;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: _WeekPill(
              week: w,
              totalKm: totalKm,
              hits: hits,
              running: running,
              isSelected: w == selectedWeek,
              isCurrent: w == currentWeek,
              onTap: () => onTap(w),
            ),
          );
        },
      ),
    );
  }
}

class _WeekPill extends StatelessWidget {
  final int week;
  final double totalKm;
  final int hits;
  final int running;
  final bool isSelected;
  final bool isCurrent;
  final VoidCallback onTap;

  const _WeekPill({
    required this.week,
    required this.totalKm,
    required this.hits,
    required this.running,
    required this.isSelected,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = running == 0 ? 0.0 : hits / running;
    return AnimatedContainer(
      duration: AppMotion.short,
      curve: AppMotion.standard,
      width: 80,
      decoration: BoxDecoration(
        color: isSelected ? cs.primary : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isCurrent && !isSelected ? cs.primary : cs.outlineVariant,
          width: isCurrent && !isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.sm, horizontal: AppSpacing.sm,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'WK',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: isSelected
                        ? cs.onPrimary.withValues(alpha: 0.7)
                        : cs.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$week',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isSelected ? cs.onPrimary : cs.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${totalKm.toStringAsFixed(0)} km',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? cs.onPrimary.withValues(alpha: 0.85)
                        : cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                if (running > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: SizedBox(
                      height: 4,
                      width: 56,
                      child: Stack(
                        children: [
                          Container(
                            color: isSelected
                                ? cs.onPrimary.withValues(alpha: 0.25)
                                : cs.surfaceContainerHigh,
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              color: isSelected
                                  ? cs.onPrimary
                                  : AppColors.pulse,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeekDetail extends StatelessWidget {
  final int weekNumber;
  final List<PlanSession> sessions;
  final bool isCurrent;

  const _WeekDetail({
    required this.weekNumber,
    required this.sessions,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalKm = sessions.fold<double>(
        0, (sum, s) => sum + s.prescribedDistanceKm);
    final running = sessions
        .where((s) =>
            s.type != SessionType.rest && s.type != SessionType.race)
        .length;
    final hits =
        sessions.where((s) => s.status == SessionStatus.hit).length;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md,
            ),
            child: Row(
              children: [
                if (isCurrent)
                  Container(
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      'NOW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: cs.onPrimary,
                      ),
                    ),
                  ),
                Text(
                  '${formatDistanceKm(totalKm, decimals: 0)}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '· $hits/$running hit',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...sessions.map((s) => _SessionRow(session: s)),
        ],
      ),
    );
  }
}

class _SessionRow extends StatelessWidget {
  final PlanSession session;
  const _SessionRow({required this.session});

  Color _typeColor(SessionType t, ColorScheme cs) => switch (t) {
        SessionType.rest => cs.outlineVariant,
        SessionType.easy => cs.primary,
        SessionType.long => AppColors.signal,
        SessionType.tempo => AppColors.warn,
        SessionType.intervals => AppColors.ember,
        SessionType.race => AppColors.ember,
      };

  IconData? _statusIcon(SessionStatus s) => switch (s) {
        SessionStatus.hit => Icons.check_circle,
        SessionStatus.partial => Icons.adjust,
        SessionStatus.missed => Icons.cancel,
        _ => null,
      };

  Color _statusColor(SessionStatus s) => switch (s) {
        SessionStatus.hit => AppColors.pulse,
        SessionStatus.partial => AppColors.warn,
        SessionStatus.missed => AppColors.miss,
        _ => AppColors.fog,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = _typeColor(session.type, cs);
    final icon = _statusIcon(session.status);
    final isRest = session.type == SessionType.rest;
    final today = DateTime.now();
    final isToday = session.scheduledDate.year == today.year &&
        session.scheduledDate.month == today.month &&
        session.scheduledDate.day == today.day;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg, vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isToday ? cs.primary.withValues(alpha: 0.06) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: isRest ? cs.outlineVariant : color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          SizedBox(
            width: 36,
            child: Text(
              shortDayName(session.scheduledDate.weekday),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
                color: isToday ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRest
                      ? 'Rest'
                      : '${session.type.label} · ${formatDistanceKm(session.prescribedDistanceKm, decimals: 1)}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (session.prescribedPaceSecPerKm != null && !isRest)
                  Text(
                    'at ${formatPace(session.prescribedPaceSecPerKm)}',
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (icon != null)
            Icon(icon, color: _statusColor(session.status), size: 18),
        ],
      ),
    );
  }
}
