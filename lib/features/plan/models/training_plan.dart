import 'plan_session.dart';

class TrainingPlan {
  final String id;
  final String userId;
  final DateTime startsOn;
  final DateTime targetMarathonDate;
  final int totalWeeks;
  final double startVdot;
  final double targetVdot;
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
