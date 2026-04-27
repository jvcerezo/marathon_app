enum SessionType {
  rest,
  easy,
  long,
  tempo,
  intervals,
  race,
}

extension SessionTypeX on SessionType {
  String get label => switch (this) {
        SessionType.rest => 'Rest',
        SessionType.easy => 'Easy',
        SessionType.long => 'Long Run',
        SessionType.tempo => 'Tempo',
        SessionType.intervals => 'Intervals',
        SessionType.race => 'Race',
      };

  bool get isRunning => this != SessionType.rest;
}

enum SessionStatus {
  scheduled,
  hit,
  partial,
  missed,
  rest,
}

class PlanSession {
  final String id;
  final String planId;
  final DateTime scheduledDate;
  final int weekNumber; // 1-based
  final int dayOfWeek; // 1=Mon ... 7=Sun
  final SessionType type;
  final double prescribedDistanceKm;

  /// Target pace as seconds per km. Null for rest days.
  final double? prescribedPaceSecPerKm;

  /// Optional notes shown to the user.
  final String? notes;

  final SessionStatus status;

  /// Linked run (if completed).
  final String? matchedRunId;

  const PlanSession({
    required this.id,
    required this.planId,
    required this.scheduledDate,
    required this.weekNumber,
    required this.dayOfWeek,
    required this.type,
    required this.prescribedDistanceKm,
    required this.status,
    this.prescribedPaceSecPerKm,
    this.notes,
    this.matchedRunId,
  });

  PlanSession copyWith({
    SessionStatus? status,
    String? matchedRunId,
    String? notes,
  }) {
    return PlanSession(
      id: id,
      planId: planId,
      scheduledDate: scheduledDate,
      weekNumber: weekNumber,
      dayOfWeek: dayOfWeek,
      type: type,
      prescribedDistanceKm: prescribedDistanceKm,
      prescribedPaceSecPerKm: prescribedPaceSecPerKm,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      matchedRunId: matchedRunId ?? this.matchedRunId,
    );
  }
}
