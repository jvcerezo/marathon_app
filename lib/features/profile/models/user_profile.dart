enum Gender { male, female, other }

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

  /// Target marathon date. Plan generator targets this.
  final DateTime targetMarathonDate;

  /// Optional goal time. Null = "just finish".
  final Duration? goalMarathonTime;

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
    required this.targetMarathonDate,
    required this.createdAt,
    required this.updatedAt,
    this.recentRunDistanceM,
    this.recentRunDuration,
    this.goalMarathonTime,
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
    DateTime? targetMarathonDate,
    Duration? goalMarathonTime,
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
      targetMarathonDate: targetMarathonDate ?? this.targetMarathonDate,
      goalMarathonTime: goalMarathonTime ?? this.goalMarathonTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
