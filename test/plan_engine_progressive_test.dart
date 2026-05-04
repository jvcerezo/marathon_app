import 'package:flutter_test/flutter_test.dart';

import 'package:daloy/features/plan/engine/plan_engine.dart';
import 'package:daloy/features/plan/models/plan_session.dart';
import 'package:daloy/features/plan/models/training_plan.dart';
import 'package:daloy/features/profile/models/user_profile.dart';

UserProfile _profile({
  bool hasRaceGoal = false,
  GoalDistance goal = GoalDistance.tenK,
  int daysPerWeek = 4,
}) {
  final now = DateTime(2026, 5, 1);
  return UserProfile(
    id: 'p',
    name: 'T',
    ageYears: 28,
    gender: Gender.male,
    heightCm: 175,
    weightKg: 70,
    fitnessLevel: FitnessLevel.beginner,
    daysPerWeek: daysPerWeek,
    goalDistance: goal,
    targetMarathonDate: now.add(const Duration(days: 365)),
    hasRaceGoal: hasRaceGoal,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('PlanEngine.generateProgressive', () {
    test('generates the requested number of weeks', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4)); // Monday
      final plan = engine.generateProgressive(_profile(), weeks: 24);
      expect(plan.totalWeeks, 24);
      // 7 sessions per week.
      expect(plan.sessions.length, 24 * 7);
    });

    test('marks itself as a maintenance-type plan (no race-day session)', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4));
      final plan = engine.generateProgressive(_profile());
      expect(plan.type, PlanType.maintenance);
      // No session should be of type race.
      expect(
        plan.sessions.where((s) => s.type == SessionType.race).isEmpty,
        true,
      );
    });

    test('volume ramps over time (week 20 > week 1)', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4));
      final plan = engine.generateProgressive(_profile(), weeks: 24);
      double weekVolume(TrainingPlan p, int w) => p.sessions
          .where((s) => s.weekNumber == w)
          .fold(0.0, (sum, s) => sum + s.prescribedDistanceKm);
      // Week 20 (deep build/consolidate) should be louder than week 1
      // (foundation start). The ramp is real, not flat.
      expect(weekVolume(plan, 20), greaterThan(weekVolume(plan, 1) * 1.5));
    });

    test('every fourth week is a 25% cutback (until the final week)', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4));
      final plan = engine.generateProgressive(_profile(), weeks: 24);
      double vol(int w) => plan.sessions
          .where((s) => s.weekNumber == w)
          .fold(0.0, (sum, s) => sum + s.prescribedDistanceKm);
      // Week 8 should be lighter than weeks 7 and 9 (cutback).
      expect(vol(8), lessThan(vol(7)));
      expect(vol(8), lessThan(vol(9)));
    });

    test('prescribed easy paces are faster by the end (fitness improving)', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4));
      final plan = engine.generateProgressive(_profile(), weeks: 24);
      double meanEasyPace(int w) {
        final easy = plan.sessions.where(
          (s) => s.weekNumber == w && s.type == SessionType.easy,
        );
        if (easy.isEmpty) return 0;
        return easy.fold<double>(
              0,
              (sum, s) => sum + (s.prescribedPaceSecPerKm ?? 0),
            ) /
            easy.length;
      }
      final start = meanEasyPace(1);
      final end = meanEasyPace(24);
      // Pace gets faster (lower seconds/km) over time as VDOT lerps.
      expect(end, lessThan(start));
    });

    test('foundation phase has no quality work', () {
      final engine = PlanEngine(now: () => DateTime(2026, 5, 4));
      final plan = engine.generateProgressive(_profile(), weeks: 24);
      // Foundation = first 30% (~7 weeks). No tempos or intervals there.
      final fdQuality = plan.sessions.where((s) =>
          s.weekNumber <= 6 &&
          (s.type == SessionType.tempo || s.type == SessionType.intervals));
      expect(fdQuality, isEmpty);
    });
  });
}
