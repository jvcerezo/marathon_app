import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/format/format.dart';
import '../../plan/models/plan_session.dart';
import '../../plan/providers/plan_providers.dart';
import '../../profile/providers/profile_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);
    final todayAsync = ref.watch(todaySessionProvider);
    final planAsync = ref.watch(activePlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {}, // future settings screen
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) context.go('/onboarding');
            });
            return const SizedBox.shrink();
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todaySessionProvider);
              ref.invalidate(activePlanProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CountdownCard(profile.targetMarathonDate),
                const SizedBox(height: 16),
                todayAsync.when(
                  loading: () => const _LoadingCard(),
                  error: (e, _) => _ErrorCard(e),
                  data: (session) => _TodaySessionCard(session: session),
                ),
                const SizedBox(height: 16),
                planAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (plan) => plan == null
                      ? const SizedBox.shrink()
                      : _WeekSummaryCard(planId: plan.id),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: todayAsync.maybeWhen(
        data: (s) => s == null || s.type == SessionType.rest
            ? null
            : FloatingActionButton.extended(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start run'),
                onPressed: () => context.push('/recording'),
              ),
        orElse: () => null,
      ),
    );
  }
}

class _CountdownCard extends StatelessWidget {
  final DateTime raceDate;
  const _CountdownCard(this.raceDate);

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = raceDate.difference(today).inDays;
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 36,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$days days',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                Text(
                  'until your marathon',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
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

class _TodaySessionCard extends StatelessWidget {
  final PlanSession? session;
  const _TodaySessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    if (session == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('No session scheduled today.'),
        ),
      );
    }
    final s = session!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s.type.label,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                _StatusChip(s.status),
              ],
            ),
            const SizedBox(height: 8),
            if (s.type == SessionType.rest)
              Text(
                'Rest day. Recovery is part of the plan.',
                style: Theme.of(context).textTheme.headlineSmall,
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    formatDistanceKm(s.prescribedDistanceKm, decimals: 1),
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 12),
                  if (s.prescribedPaceSecPerKm != null)
                    Text(
                      'at ${formatPace(s.prescribedPaceSecPerKm)}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                ],
              ),
            if (s.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                s.notes!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final SessionStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      SessionStatus.scheduled => (Colors.blue, 'Scheduled'),
      SessionStatus.hit => (Colors.green, 'Hit'),
      SessionStatus.partial => (Colors.orange, 'Partial'),
      SessionStatus.missed => (Colors.red, 'Missed'),
      SessionStatus.rest => (Colors.grey, 'Rest'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class _WeekSummaryCard extends ConsumerWidget {
  final String planId;
  const _WeekSummaryCard({required this.planId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingAsync = ref.watch(upcomingSessionsProvider);
    return upcomingAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (sessions) {
        if (sessions.isEmpty) return const SizedBox.shrink();
        final next7 = sessions.take(7).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This week',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ...next7.map(
                  (s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text(
                            _shortDay(s.scheduledDate),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            s.type == SessionType.rest
                                ? 'Rest'
                                : '${s.type.label} · ${formatDistanceKm(s.prescribedDistanceKm, decimals: 1)}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _shortDay(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final Object error;
  const _ErrorCard(this.error);
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text('Could not load: $error'),
      ),
    );
  }
}
