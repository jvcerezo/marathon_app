import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../plan/models/plan_session.dart';
import '../../plan/providers/plan_providers.dart';
import '../../runs/providers/runs_providers.dart';

class HomeStats {
  final int streakDays;
  final double thisWeekKm;
  final double thisWeekTargetKm;
  final double adherence; // 0..1
  final int hits;
  final int total;

  const HomeStats({
    required this.streakDays,
    required this.thisWeekKm,
    required this.thisWeekTargetKm,
    required this.adherence,
    required this.hits,
    required this.total,
  });
}

final homeStatsProvider = FutureProvider<HomeStats>((ref) async {
  final plan = await ref.watch(activePlanProvider.future);
  final runs = await ref.watch(runsProvider.future);

  // Streak: consecutive days with a run, allowing single-day rest gaps.
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

  // This week (Monday → Sunday): logged vs prescribed.
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final mondayOffset = (today.weekday - DateTime.monday) % 7;
  final monday = today.subtract(Duration(days: mondayOffset));
  final nextMonday = monday.add(const Duration(days: 7));

  double weekKm = 0;
  for (final r in runs) {
    if (!r.startedAt.isBefore(monday) && r.startedAt.isBefore(nextMonday)) {
      weekKm += r.distanceKm;
    }
  }

  double weekTargetKm = 0;
  if (plan != null) {
    for (final s in plan.sessions) {
      if (!s.scheduledDate.isBefore(monday) &&
          s.scheduledDate.isBefore(nextMonday)) {
        weekTargetKm += s.prescribedDistanceKm;
      }
    }
  }

  // Adherence across the entire plan to date.
  int hits = 0, total = 0;
  if (plan != null) {
    for (final s in plan.sessions) {
      if (s.status == SessionStatus.hit) {
        hits++;
        total++;
      } else if (s.status == SessionStatus.partial ||
          s.status == SessionStatus.missed) {
        total++;
      }
    }
  }
  final adherence = total == 0 ? 0.0 : hits / total;

  return HomeStats(
    streakDays: streak,
    thisWeekKm: weekKm,
    thisWeekTargetKm: weekTargetKm,
    adherence: adherence,
    hits: hits,
    total: total,
  );
});
