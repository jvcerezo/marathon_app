import 'models/training_plan.dart';

enum PlanPhase {
  /// No plan saved at all — user is on a break or hasn't onboarded yet.
  none,

  /// Open-ended maintenance plan running.
  maintenance,

  /// Training toward a race, more than a week out.
  preRace,

  /// Final week before the race.
  raceWeek,

  /// Today is race day.
  raceDay,

  /// 1-7 days after race day. Recovery phase, no work prescribed.
  recovery,

  /// Past race + 7 days. Race plan is over and the user hasn't picked
  /// a next step.
  complete,
}

class PlanState {
  final PlanPhase phase;

  /// Days remaining until race day. Null when phase is post-race or no plan.
  final int? daysToRace;

  /// Days since race day. Null when phase is pre-race or no plan.
  final int? daysSinceRace;

  final TrainingPlan? plan;

  const PlanState._({
    required this.phase,
    required this.plan,
    this.daysToRace,
    this.daysSinceRace,
  });

  factory PlanState.from(TrainingPlan? plan, DateTime now) {
    if (plan == null) {
      return const PlanState._(phase: PlanPhase.none, plan: null);
    }
    if (plan.type == PlanType.maintenance) {
      return PlanState._(phase: PlanPhase.maintenance, plan: plan);
    }
    final today = DateTime(now.year, now.month, now.day);
    final race = DateTime(
      plan.targetMarathonDate.year,
      plan.targetMarathonDate.month,
      plan.targetMarathonDate.day,
    );
    final diffDays = today.difference(race).inDays;
    if (diffDays < -7) {
      return PlanState._(
        phase: PlanPhase.preRace,
        plan: plan,
        daysToRace: -diffDays,
      );
    }
    if (diffDays < 0) {
      return PlanState._(
        phase: PlanPhase.raceWeek,
        plan: plan,
        daysToRace: -diffDays,
      );
    }
    if (diffDays == 0) {
      return PlanState._(
        phase: PlanPhase.raceDay,
        plan: plan,
        daysToRace: 0,
        daysSinceRace: 0,
      );
    }
    if (diffDays <= 7) {
      return PlanState._(
        phase: PlanPhase.recovery,
        plan: plan,
        daysSinceRace: diffDays,
      );
    }
    return PlanState._(
      phase: PlanPhase.complete,
      plan: plan,
      daysSinceRace: diffDays,
    );
  }
}
