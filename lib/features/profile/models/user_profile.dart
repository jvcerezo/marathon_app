enum Gender { male, female, other }

enum GoalDistance {
  fiveK(5000, '5K', 6, 16),
  tenK(10000, '10K', 8, 20),
  halfMarathon(21097.5, 'Half Marathon', 10, 24),
  marathon(42195, 'Marathon', 16, 60);

  /// Race distance in meters.
  final double meters;
  final String label;

  /// Minimum recommended weeks of training before the race.
  final int minWeeks;

  /// Maximum the engine will plan for (caps overly long timelines).
  final int maxWeeks;

  const GoalDistance(this.meters, this.label, this.minWeeks, this.maxWeeks);

  double get km => meters / 1000.0;
}

enum FitnessLevel {
  /// Cannot run a continuous mile right now.
  none,

  /// Runs occasionally, no structured training.
  beginner,

  /// Runs regularly, comfortable with 5 km.
  recreational,

  /// Has completed a 10 km or longer.
  intermediate,
}

class UserProfile {
  final String id;
  final String name;
  final int ageYears;
  final Gender gender;
  final double heightCm;
  final double weightKg;
  final FitnessLevel fitnessLevel;

  /// Optional baseline assessment: best recent run distance + time.
  /// Used to anchor predictions when present.
  final double? recentRunDistanceM;
  final Duration? recentRunDuration;

  /// Days the user wants to run per week. Drives plan density.
  final int daysPerWeek;

  /// What distance the user is training for.
  final GoalDistance goalDistance;

  /// Target race date. Used by the plan generator only when
  /// [hasRaceGoal] is true; otherwise the field is held but ignored
  /// (we keep storing a value so existing rows don't need a complex
  /// nullable migration).
  final DateTime targetMarathonDate;

  /// Optional goal time. Null = "just finish".
  final Duration? goalMarathonTime;

  /// True = user is training for a specific race day; the plan tapers
  /// to that date. False = open-ended progressive plan that ramps
  /// volume + introduces quality without a race anchor.
  final bool hasRaceGoal;

  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.name,
    required this.ageYears,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.fitnessLevel,
    required this.daysPerWeek,
    required this.goalDistance,
    required this.targetMarathonDate,
    required this.createdAt,
    required this.updatedAt,
    this.recentRunDistanceM,
    this.recentRunDuration,
    this.goalMarathonTime,
    this.hasRaceGoal = true,
  });

  /// First name only, useful for compact greetings.
  String get firstName {
    final t = name.trim();
    if (t.isEmpty) return '';
    final parts = t.split(RegExp(r'\s+'));
    return parts.first;
  }

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  UserProfile copyWith({
    String? name,
    int? ageYears,
    Gender? gender,
    double? heightCm,
    double? weightKg,
    FitnessLevel? fitnessLevel,
    double? recentRunDistanceM,
    Duration? recentRunDuration,
    int? daysPerWeek,
    GoalDistance? goalDistance,
    DateTime? targetMarathonDate,
    Duration? goalMarathonTime,
    bool? hasRaceGoal,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      ageYears: ageYears ?? this.ageYears,
      gender: gender ?? this.gender,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      recentRunDistanceM: recentRunDistanceM ?? this.recentRunDistanceM,
      recentRunDuration: recentRunDuration ?? this.recentRunDuration,
      daysPerWeek: daysPerWeek ?? this.daysPerWeek,
      goalDistance: goalDistance ?? this.goalDistance,
      targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
      goalMarathonTime: goalMarathonTime ?? this.goalMarathonTime,
      hasRaceGoal: hasRaceGoal ?? this.hasRaceGoal,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
