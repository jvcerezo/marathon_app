import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../engine/plan_engine.dart';
import '../models/plan_session.dart';
import '../models/training_plan.dart';

final activePlanProvider = FutureProvider<TrainingPlan?>((ref) async {
  return ref.watch(planRepositoryProvider).active();
});

final planEngineProvider = Provider<PlanEngine>((ref) => PlanEngine());

/// Today's session for the active plan.
final todaySessionProvider = FutureProvider<PlanSession?>((ref) async {
  final plan = await ref.watch(activePlanProvider.future);
  if (plan == null) return null;
  final today = DateTime.now();
  return ref
      .watch(planRepositoryProvider)
      .sessionForDate(plan.id, today);
});

final upcomingSessionsProvider =
    FutureProvider<List<PlanSession>>((ref) async {
  final plan = await ref.watch(activePlanProvider.future);
  if (plan == null) return [];
  final today = DateTime.now();
  final start = DateTime(today.year, today.month, today.day);
  return ref.watch(planRepositoryProvider).sessionsInRange(
        plan.id,
        start,
        start.add(const Duration(days: 14)),
      );
});

