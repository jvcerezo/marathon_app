import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/tokens.dart';
import '../../../core/design/widgets/arc_progress.dart';
import '../../../core/design/widgets/hero_number.dart';
import '../../../core/design/widgets/section_label.dart';
import '../../../core/design/widgets/status_pill.dart';
import '../../../core/format/format.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/models/training_plan.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/providers/profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final todayAsync = ref.watch(todaySessionProvider);
    final planAsync = ref.watch(activePlanProvider);
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
          return RefreshIndicator(
            color: cs.primary,
            onRefresh: () async {
              ref.invalidate(todaySessionProvider);
              ref.invalidate(activePlanProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: false,
                  floating: true,
                  backgroundColor: cs.surface,
                  elevation: 0,
                  toolbarHeight: 0,
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.huge,
                  ),
                  sliver: SliverList.list(
                    children: [
                      _GreetingHeader(profile: profile),
                      const SizedBox(height: AppSpacing.xl),
                      _CountdownCard(profile: profile),
                      const SizedBox(height: AppSpacing.lg),
                      todayAsync.when(
                        loading: () => const _LoadingTile(),
                        error: (e, _) => _ErrorTile('$e'),
                        data: (session) => _TodayCard(session: session),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      planAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (plan) => plan == null
                            ? const SizedBox.shrink()
                            : _WeekStrip(plan: plan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: todayAsync.maybeWhen(
        data: (s) {
          if (s == null || s.type == SessionType.rest) return null;
          return FloatingActionButton.extended(
            heroTag: 'startRun',
            onPressed: () => context.push('/recording'),
            backgroundColor: cs.primary,
            foregroundColor: cs.onPrimary,
            elevation: 0,
            extendedPadding: const EdgeInsets.symmetric(horizontal: 28),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'Start run',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
}

class _GreetingHeader extends StatelessWidget {
  final UserProfile profile;
  const _GreetingHeader({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final greeting = greetingFor(DateTime.now());
    final name = profile.firstName;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(monthDay(DateTime.now())),
              const SizedBox(height: AppSpacing.sm),
              Text(
                name.isEmpty ? '$greeting.' : '$greeting, $name.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.settings_outlined, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final UserProfile profile;
  const _CountdownCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final daysToRace = profile.targetMarathonDate.difference(today).inDays;
    // Plan starts 365 days back from race; progress is how far along we are.
    final totalDays = 365;
    final daysElapsed = (totalDays - daysToRace).clamp(0, totalDays);
    final progress = daysElapsed / totalDays;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xxl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          ArcProgress(
            progress: progress,
            size: 120,
            strokeWidth: 10,
            trackColor: cs.surfaceContainerHigh,
            progressColor: cs.primary,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeroNumber('$daysToRace', size: 36),
                Text(
                  'DAYS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.4,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel('Race day', color: cs.primary),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  monthDay(profile.targetMarathonDate),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '${profile.targetMarathonDate.year}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${(progress * 100).round()}% through your plan',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: AppMotion.short);
  }
}

class _TodayCard extends StatelessWidget {
  final PlanSession? session;
  const _TodayCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (session == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          'No session scheduled today.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final s = session!;
    final isRest = s.type == SessionType.rest;
    final accent = _accentFor(s.type, cs);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top accent stripe
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.xl),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SectionLabel("Today's session", color: accent),
                    _StatusPill(status: s.status),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  s.type.label,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (isRest) ...[
                  Text(
                    'Recovery is part of the plan.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ] else ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      HeroNumber(
                        s.prescribedDistanceKm.toStringAsFixed(1),
                        unit: 'km',
                        size: 56,
                      ),
                    ],
                  ),
                  if (s.prescribedPaceSecPerKm != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Target pace ${formatPace(s.prescribedPaceSecPerKm)}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                  if (s.notes != null) ...[
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Text(
                        s.notes!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: AppMotion.short,
          delay: const Duration(milliseconds: 80),
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

class _StatusPill extends StatelessWidget {
  final SessionStatus status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label, icon) = switch (status) {
      SessionStatus.scheduled => (AppColors.signal, 'Scheduled', null),
      SessionStatus.hit => (AppColors.pulse, 'Hit', Icons.check),
      SessionStatus.partial => (AppColors.warn, 'Partial', null),
      SessionStatus.missed => (AppColors.miss, 'Missed', null),
      SessionStatus.rest => (Theme.of(context).colorScheme.onSurfaceVariant, 'Rest', null),
    };
    return StatusPill(label: label, color: color, icon: icon);
  }
}

class _WeekStrip extends ConsumerWidget {
  final TrainingPlan plan;
  const _WeekStrip({required this.plan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingSessionsProvider);
    return upcomingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final next7 = sessions.take(7).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              child: const SectionLabel('This week'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: next7
                  .map(
                    (s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: _DayCell(session: s),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        );
      },
    );
  }
}

class _DayCell extends StatelessWidget {
  final PlanSession session;
  const _DayCell({required this.session});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final isToday = session.scheduledDate.year == today.year &&
        session.scheduledDate.month == today.month &&
        session.scheduledDate.day == today.day;
    final accent = switch (session.status) {
      SessionStatus.hit => AppColors.pulse,
      SessionStatus.partial => AppColors.warn,
      SessionStatus.missed => AppColors.miss,
      _ => cs.surfaceContainerHigh,
    };
    final isRest = session.type == SessionType.rest;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isToday ? cs.primaryContainer : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isToday ? cs.primary : cs.outlineVariant,
          width: isToday ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            shortDayName(session.scheduledDate.weekday)[0],
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: isToday ? cs.onPrimaryContainer : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isRest
                  ? cs.outlineVariant
                  : (session.status == SessionStatus.scheduled
                      ? (isToday ? cs.primary : cs.onSurfaceVariant)
                      : accent),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            isRest ? '–' : session.prescribedDistanceKm.toStringAsFixed(0),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isToday ? cs.onPrimaryContainer : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: const Center(child: CircularProgressIndicator()),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  final String message;
  const _ErrorTile(this.message);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.miss.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Text(message),
    );
  }
}
