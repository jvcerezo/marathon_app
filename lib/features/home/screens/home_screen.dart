import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/status_pill.dart';
import '../../../core/format/format.dart';
import '../../../core/providers/providers.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/models/training_plan.dart';
import '../../plan/plan_state.dart';
import '../../plan/providers/plan_providers.dart';
import '../../plan/widgets/new_goal_sheet.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';
import '../providers/home_stats_provider.dart';

List<Widget> _bodyForState(
  BuildContext context,
  WidgetRef ref,
  UserProfile profile,
  PlanState state,
) {
  final header = _Header(profile: profile);
  switch (state.phase) {
    case PlanPhase.none:
      return [
        header,
        const SizedBox(height: AppSpacing.xl),
        const _NoPlanBanner(),
      ];
    case PlanPhase.complete:
      return [
        header,
        const SizedBox(height: AppSpacing.xl),
        _CompleteBanner(profile: profile, daysSince: state.daysSinceRace ?? 0),
      ];
    case PlanPhase.recovery:
      return [
        header,
        const SizedBox(height: AppSpacing.xl),
        _RecoveryHero(daysSince: state.daysSinceRace ?? 0),
        const SizedBox(height: AppSpacing.lg),
        _StatsForState(),
      ];
    case PlanPhase.raceDay:
      return [
        header,
        const SizedBox(height: AppSpacing.xl),
        _RaceDayHero(profile: profile),
      ];
    case PlanPhase.raceWeek:
    case PlanPhase.preRace:
    case PlanPhase.maintenance:
      return [
        header,
        const SizedBox(height: AppSpacing.xl),
        _TodayHeroLoader(state: state),
        const SizedBox(height: AppSpacing.lg),
        _StatsForState(),
        const SizedBox(height: AppSpacing.lg),
        _WeekStripLoader(),
        if (state.phase != PlanPhase.maintenance) ...[
          const SizedBox(height: AppSpacing.lg),
          _RaceCountdown(profile: profile),
        ],
      ];
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/onboarding');
            });
            return const SizedBox.shrink();
          }
          return SafeArea(
            bottom: false,
            child: RefreshIndicator(
              color: cs.primary,
              onRefresh: () async {
                ref.invalidate(todaySessionProvider);
                ref.invalidate(activePlanProvider);
                ref.invalidate(homeStatsProvider);
                ref.invalidate(planStateProvider);
              },
              child: Consumer(
                builder: (context, ref, _) {
                  final stateAsync = ref.watch(planStateProvider);
                  return stateAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('$e')),
                    data: (state) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.md, AppSpacing.lg,
                        AppSpacing.fabSafe,
                      ),
                      children: _bodyForState(context, ref, profile, state),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final UserProfile profile;
  const _Header({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final greeting = greetingFor(DateTime.now());
    final name = profile.firstName;
    final today = DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(
                '${shortDayName(today.weekday).toUpperCase()} · ${monthDay(today).toUpperCase()}',
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name.isEmpty ? '$greeting.' : '$greeting, $name.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        Material(
          color: cs.surfaceContainerLow,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.push('/settings'),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(
                name.isEmpty ? 'M' : name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroToday extends StatelessWidget {
  final PlanSession? session;
  const _HeroToday({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (session == null) {
      return _emptyShell(context, 'No session scheduled today.');
    }
    final s = session!;
    if (s.type == SessionType.rest) {
      return _RestHero(session: s);
    }
    final accent = _accentFor(s.type, cs);
    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(AppRadius.xxl),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        onTap: () => context.push('/recording'),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.xxl),
            border: Border.all(color: cs.outlineVariant),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'TODAY · ${s.type.label.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.6,
                      color: accent,
                    ),
                  ),
                  const Spacer(),
                  _SessionStatusPill(status: s.status),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 88,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -3,
                              height: 0.95,
                              color: cs.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                            text: s.prescribedDistanceKm
                                .toStringAsFixed(s.prescribedDistanceKm
                                            .truncateToDouble() ==
                                        s.prescribedDistanceKm
                                    ? 0
                                    : 1),
                            children: [
                              TextSpan(
                                text: ' km',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (s.prescribedPaceSecPerKm != null) ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'target ${formatPace(s.prescribedPaceSecPerKm)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: cs.onPrimary,
                      size: 36,
                    ),
                  ),
                ],
              ),
              if (s.notes != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          s.notes!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: AppMotion.short).moveY(begin: 8, end: 0);
  }

  Widget _emptyShell(BuildContext context, String label) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
    );
  }

  Color _accentFor(SessionType t, ColorScheme cs) => switch (t) {
        SessionType.rest => cs.onSurfaceVariant,
        SessionType.easy => cs.primary,
        SessionType.long => AppColors.signal,
        SessionType.tempo => AppColors.warn,
        SessionType.intervals => AppColors.ember,
        SessionType.race => AppColors.ember,
      };
}

class _RestHero extends StatelessWidget {
  final PlanSession session;
  const _RestHero({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel('TODAY · REST'),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Take it easy.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Recovery is when adaptation happens.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(Icons.bedtime_outlined, color: cs.onSurfaceVariant),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Sleep, hydrate, and stretch.',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SessionStatusPill extends StatelessWidget {
  final SessionStatus status;
  const _SessionStatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      SessionStatus.scheduled => (AppColors.signal, 'Scheduled', null),
      SessionStatus.hit => (AppColors.pulse, 'Hit', Icons.check),
      SessionStatus.partial => (AppColors.warn, 'Partial', null),
      SessionStatus.missed => (AppColors.miss, 'Missed', null),
      SessionStatus.rest =>
        (Theme.of(context).colorScheme.onSurfaceVariant, 'Rest', null),
    };
    return StatusPill(label: label, color: color, icon: icon);
  }
}

class _StatsTriad extends StatelessWidget {
  final HomeStats stats;
  const _StatsTriad({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        children: [
          Expanded(
            child: _StreakStat(days: stats.streakDays),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MiniStat(
              label: 'This week',
              value: stats.thisWeekKm.toStringAsFixed(0),
              unit: stats.thisWeekTargetKm == 0
                  ? 'km'
                  : 'of ${stats.thisWeekTargetKm.toStringAsFixed(0)}',
              accent: cs.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _MiniStat(
              label: 'Adherence',
              value: stats.total == 0
                  ? '–'
                  : '${(stats.adherence * 100).round()}',
              unit: stats.total == 0 ? '' : '%',
              accent: AppColors.signal,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color accent;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: cs.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              text: value,
              children: unit.isEmpty
                  ? null
                  : [
                      TextSpan(
                        text: ' $unit',
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
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final TrainingPlan plan;
  final List<PlanSession> sessions;

  const _WeekStrip({required this.plan, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final dayOnly = DateTime(today.year, today.month, today.day);
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
          const SectionLabel('Next 7 days'),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: sessions
                .map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _DayCell(
                          session: s,
                          isToday: DateTime(
                                s.scheduledDate.year,
                                s.scheduledDate.month,
                                s.scheduledDate.day,
                              ) ==
                              dayOnly,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final PlanSession session;
  final bool isToday;

  const _DayCell({required this.session, required this.isToday});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isRest = session.type == SessionType.rest;
    final stateColor = switch (session.status) {
      SessionStatus.hit => AppColors.pulse,
      SessionStatus.partial => AppColors.warn,
      SessionStatus.missed => AppColors.miss,
      _ => cs.outlineVariant,
    };

    final fillColor =
        isToday ? cs.primary : (isRest ? cs.surfaceContainerHigh : stateColor);
    final textOnFill = isToday
        ? cs.onPrimary
        : (isRest ? cs.onSurfaceVariant : AppColors.ink);

    return Column(
      children: [
        Text(
          shortDayName(session.scheduledDate.weekday)[0],
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${session.scheduledDate.day}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          height: 32,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            isRest ? '–' : session.prescribedDistanceKm.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textOnFill,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _RaceCountdown extends StatelessWidget {
  final UserProfile profile;
  const _RaceCountdown({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysToRace =
        profile.targetMarathonDate.difference(DateTime.now()).inDays;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: cs.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Race day',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${monthDay(profile.targetMarathonDate)}, ${profile.targetMarathonDate.year}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: cs.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              text: '$daysToRace',
              children: [
                TextSpan(
                  text: ' days',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
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

class _SkeletonHero extends StatelessWidget {
  const _SkeletonHero();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

// =================== STATE-AWARE WRAPPERS ===================

class _TodayHeroLoader extends ConsumerWidget {
  final PlanState state;
  const _TodayHeroLoader({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todaySessionProvider);
    final stateBadge = switch (state.phase) {
      PlanPhase.raceWeek =>
        _StateBadge('RACE WEEK', AppColors.ember, PhosphorIconsRegular.flag),
      PlanPhase.maintenance =>
        _StateBadge('MAINTENANCE', AppColors.signal, PhosphorIconsRegular.heartbeat),
      _ => null,
    };
    return today.when(
      loading: () => const _SkeletonHero(),
      error: (e, _) => Text('$e'),
      data: (s) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (stateBadge != null) ...[
            stateBadge,
            const SizedBox(height: AppSpacing.sm),
          ],
          _HeroToday(session: s),
        ],
      ),
    );
  }
}

class _StateBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _StateBadge(this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsForState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);
    return stats.when(
      loading: () => const SizedBox(height: 88),
      error: (e, _) => Text('$e'),
      data: (s) => _StatsTriad(stats: s),
    );
  }
}

class _WeekStripLoader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingSessionsProvider);
    final planAsync = ref.watch(activePlanProvider);
    return planAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (plan) {
        if (plan == null) return const SizedBox.shrink();
        return upcomingAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (sessions) => _WeekStrip(
            plan: plan,
            sessions: sessions.take(7).toList(),
          ),
        );
      },
    );
  }
}

// =================== POST-RACE STATES ===================

class _RaceDayHero extends StatelessWidget {
  final UserProfile profile;
  const _RaceDayHero({required this.profile});

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
            AppColors.ember.withValues(alpha: 0.25),
            AppColors.ember.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: AppColors.ember.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.ember.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  PhosphorIconsDuotone.medal,
                  color: AppColors.ember,
                  size: 36,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel('TODAY · RACE DAY', color: AppColors.ember),
                    const SizedBox(height: 4),
                    Text(
                      'It\'s race day.',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            profile.name.isEmpty
                ? 'A whole training cycle led here. Trust the work.'
                : '${profile.firstName}, a whole training cycle led here. Trust the work.',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Icon(PhosphorIconsRegular.ruler, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                '${profile.goalDistance.km.toStringAsFixed(profile.goalDistance.km == profile.goalDistance.km.truncateToDouble() ? 0 : 2)} km',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Icon(PhosphorIconsRegular.flag, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(
                profile.goalDistance.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.short);
  }
}

class _RecoveryHero extends StatelessWidget {
  final int daysSince;
  const _RecoveryHero({required this.daysSince});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final daysToReboot = (7 - daysSince).clamp(0, 7);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(PhosphorIconsDuotone.bed, color: cs.primary, size: 24),
              const SizedBox(width: 8),
              SectionLabel('RECOVERY WEEK', color: cs.primary),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            "Race is done. Take it easy.",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              height: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            "Walk, easy spin, sleep. No prescribed sessions until your body's back. We'll prompt you for what's next in $daysToReboot ${daysToReboot == 1 ? 'day' : 'days'}.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: cs.surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: (daysSince / 7).clamp(0, 1).toDouble(),
                    child: Container(color: cs.primary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompleteBanner extends ConsumerWidget {
  final UserProfile profile;
  final int daysSince;
  const _CompleteBanner({required this.profile, required this.daysSince});

  Future<void> _planAnotherRace(
      BuildContext context, WidgetRef ref) async {
    final ok = await showNewGoalSheet(context, profile);
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New plan generated.')),
      );
    }
  }

  Future<void> _maintainFitness(
      BuildContext context, WidgetRef ref) async {
    final engine = ref.read(planEngineProvider);
    final plan = engine.generateMaintenance(profile);
    await ref.read(planRepositoryProvider).save(plan);
    ref.invalidate(activePlanProvider);
    ref.invalidate(todaySessionProvider);
    ref.invalidate(upcomingSessionsProvider);
    ref.invalidate(planStateProvider);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maintenance plan started.')),
      );
    }
  }

  Future<void> _takeBreak(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Take a break?'),
        content: const Text(
          "We'll clear your training plan. Recording still works for ad-hoc runs. Come back any time and pick a new goal.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(c).pop(true),
            child: const Text('Take a break'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(planRepositoryProvider).clearActive();
    ref.invalidate(activePlanProvider);
    ref.invalidate(todaySessionProvider);
    ref.invalidate(upcomingSessionsProvider);
    ref.invalidate(planStateProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
              Icon(PhosphorIconsDuotone.medal, color: cs.primary, size: 36),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Plan complete.',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                "You wrapped a full ${profile.goalDistance.label} cycle. What's next?",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _ChoiceTile(
          icon: PhosphorIconsDuotone.flag,
          accent: cs.primary,
          title: 'Plan another race',
          subtitle: 'Pick a new distance and date. Your fitness carries forward.',
          onTap: () => _planAnotherRace(context, ref),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChoiceTile(
          icon: PhosphorIconsDuotone.heartbeat,
          accent: AppColors.signal,
          title: 'Maintain fitness',
          subtitle: 'Open-ended easy plan. Hold the gains, no race pressure.',
          onTap: () => _maintainFitness(context, ref),
        ),
        const SizedBox(height: AppSpacing.sm),
        _ChoiceTile(
          icon: PhosphorIconsDuotone.coffee,
          accent: AppColors.fog,
          title: 'Take a break',
          subtitle: 'Clear your plan. Come back when you\'re ready.',
          onTap: () => _takeBreak(context, ref),
        ),
      ],
    );
  }
}

class _NoPlanBanner extends ConsumerWidget {
  const _NoPlanBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(PhosphorIconsDuotone.flag, color: cs.primary, size: 36),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No active plan.',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Recording still works for ad-hoc runs. Set a new goal whenever you\'re ready.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Consumer(
            builder: (context, ref, _) {
              final profileAsync = ref.watch(profileProvider);
              return profileAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) => profile == null
                    ? const SizedBox.shrink()
                    : FilledButton.icon(
                        onPressed: () async {
                          await showNewGoalSheet(context, profile);
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Pick a new goal'),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

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
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
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

/// Streak counter with a flame icon. The flame fills with ember color
/// once the user has any active streak; double-flame appears at the
/// 7-day mark to signal a real habit. Cold/gray when streak is zero.
class _StreakStat extends StatelessWidget {
  final int days;
  const _StreakStat({required this.days});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final active = days >= 1;
    final hot = days >= 7;
    final flameColor = active ? AppColors.ember : AppColors.smoke;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md, vertical: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                PhosphorIconsFill.flame,
                color: flameColor,
                size: 14,
              ),
              if (hot) ...[
                const SizedBox(width: 2),
                const Icon(
                  PhosphorIconsFill.flame,
                  color: AppColors.ember,
                  size: 14,
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'STREAK',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: hot ? AppColors.ember : cs.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              text: '$days',
              children: [
                TextSpan(
                  text: days == 1 ? ' day' : ' days',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                    letterSpacing: 0.4,
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
