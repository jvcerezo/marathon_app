import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (plan) {
          if (plan == null) {
            return const Center(child: Text('No plan generated yet.'));
          }
          final byWeek = <int, List<PlanSession>>{};
          for (final s in plan.sessions) {
            byWeek.putIfAbsent(s.weekNumber, () => []).add(s);
          }
          final weeks = byWeek.keys.toList()..sort();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 24),
            itemCount: weeks.length,
            itemBuilder: (context, i) {
              final weekNum = weeks[i];
              final weekSessions = byWeek[weekNum]!;
              final totalKm = weekSessions.fold<double>(
                  0, (sum, s) => sum + s.prescribedDistanceKm);
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  title: Text('Week $weekNum'),
                  subtitle: Text(
                    '${formatDistanceKm(totalKm, decimals: 1)} · '
                    '${_phaseFor(weekNum)}',
                  ),
                  children: weekSessions
                      .map(
                        (s) => ListTile(
                          dense: true,
                          leading: SizedBox(
                            width: 44,
                            child: Text(_dayShort(s.scheduledDate)),
                          ),
                          title: Text(
                            s.type == SessionType.rest
                                ? 'Rest'
                                : '${s.type.label} · ${formatDistanceKm(s.prescribedDistanceKm, decimals: 1)}',
                          ),
                          subtitle: s.prescribedPaceSecPerKm == null
                              ? null
                              : Text('@ ${formatPace(s.prescribedPaceSecPerKm)}'),
                          trailing: _statusIcon(s.status),
                        ),
                      )
                      .toList(),
                ),
              );
            },
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

  String _dayShort(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }

  Widget? _statusIcon(SessionStatus s) => switch (s) {
        SessionStatus.hit =>
          const Icon(Icons.check_circle, color: Colors.green, size: 18),
        SessionStatus.partial =>
          const Icon(Icons.adjust, color: Colors.orange, size: 18),
        SessionStatus.missed =>
          const Icon(Icons.cancel_outlined, color: Colors.red, size: 18),
        _ => null,
      };
}
