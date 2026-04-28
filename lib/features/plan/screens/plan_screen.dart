import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/format/format.dart';
import '../models/plan_session.dart';
import '../providers/plan_providers.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md,
                ),
                sliver: SliverToBoxAdapter(
                  child: _PhaseStrip(currentWeek: currentWeek),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.huge,
                ),
                sliver: SliverList.separated(
                  itemCount: weeks.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final w = weeks[i];
                    return _WeekCard(
                      weekNumber: w,
                      sessions: byWeek[w]!,
                      isCurrent: w == currentWeek,
                      initiallyExpanded: w == currentWeek,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Phase'),
        const SizedBox(height: AppSpacing.md),
        Row(
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
                      height: 6,
                      decoration: BoxDecoration(
                        color: isActive ? cs.primary : cs.outlineVariant,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                        color: isActive ? cs.primary : cs.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  final int weekNumber;
  final List<PlanSession> sessions;
  final bool isCurrent;
  final bool initiallyExpanded;

  const _WeekCard({
    required this.weekNumber,
    required this.sessions,
    required this.isCurrent,
    required this.initiallyExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final totalKm = sessions.fold<double>(
        0, (sum, s) => sum + s.prescribedDistanceKm);
    final hits =
        sessions.where((s) => s.status == SessionStatus.hit).length;
    final runningCount = sessions
        .where((s) => s.type != SessionType.rest && s.type != SessionType.race)
        .length;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: isCurrent ? cs.primary : cs.outlineVariant,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          title: Row(
            children: [
              Text(
                'Week $weekNumber',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isCurrent)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'NOW',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: cs.onPrimary,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${formatDistanceKm(totalKm, decimals: 0)}'
              '${runningCount == 0 ? '' : ' · $hits/$runningCount hit'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          childrenPadding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
          children: sessions
              .map((s) => _SessionRow(session: s))
              .toList(),
        ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
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
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              isRest
                  ? 'Rest'
                  : '${session.type.label} · ${formatDistanceKm(session.prescribedDistanceKm, decimals: 1)}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          if (icon != null)
            Icon(icon, color: _statusColor(session.status), size: 18),
        ],
      ),
    );
  }
}
