import 'plan_session.dart';

enum PlanType {
  race,
  maintenance,
  // The "break" state is represented as the absence of an active plan,
  // not a plan with type=break. Keeping the enum to two values means we
  // never accidentally show sessions during a break.
}

class TrainingPlan {
  final String id;
  final String userId;
  final DateTime startsOn;
  final DateTime targetMarathonDate;
  final int totalWeeks;
  final double startVdot;
  final double targetVdot;
  final PlanType type;
  final List<PlanSession> sessions;

  const TrainingPlan({
    required this.id,
    required this.userId,
    required this.startsOn,
    required this.targetMarathonDate,
    required this.totalWeeks,
    required this.startVdot,
    required this.targetVdot,
    required this.sessions,
    this.type = PlanType.race,
  });

  PlanSession? sessionForDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    for (final s in sessions) {
      final sd = DateTime(
        s.scheduledDate.year,
        s.scheduledDate.month,
        s.scheduledDate.day,
      );
      if (sd == d) return s;
    }
    return null;
  }

  double weeklyMileageKm(int week) {
    return sessions
        .where((s) => s.weekNumber == week)
        .fold<double>(0, (sum, s) => sum + s.prescribedDistanceKm);
  }
}
