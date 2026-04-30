import 'package:flutter_test/flutter_test.dart';

import 'package:bakas/features/fitness/predictor.dart';
import 'package:bakas/features/plan/engine/plan_engine.dart';
import 'package:bakas/features/plan/models/plan_session.dart';
import 'package:bakas/features/profile/models/user_profile.dart';

void main() {
  test('Riegel sanity: marathon time roughly 2x half marathon at same VDOT',
      () {
    const vdot = 45.0;
    final half = predictRaceTime(vdot, kHalfMarathon);
    final full = predictRaceTime(vdot, kMarathon);
    expect(full.inSeconds > half.inSeconds * 2, true);
    expect(full.inSeconds < half.inSeconds * 2.2, true);
  });

  test('VDOT from race: faster time = higher VDOT', () {
    final slowMarathon = vdotFromRace(kMarathon, const Duration(hours: 5));
    final fastMarathon =
        vdotFromRace(kMarathon, const Duration(hours: 3, minutes: 30));
    expect(fastMarathon > slowMarathon, true);
  });

  group('PlanEngine', () {
    UserProfile sampleProfile({
      GoalDistance goal = GoalDistance.marathon,
      int weeksUntilRace = 52,
      int daysPerWeek = 4,
    }) {
      final now = DateTime(2026, 4, 28); // a Tuesday
      return UserProfile(
        id: 'test',
        name: 'Test',
        ageYears: 28,
        gender: Gender.male,
        heightCm: 175,
        weightKg: 70,
        fitnessLevel: FitnessLevel.beginner,
        daysPerWeek: daysPerWeek,
        goalDistance: goal,
        targetMarathonDate: now.add(Duration(days: weeksUntilRace * 7)),
        createdAt: now,
        updatedAt: now,
      );
    }

    test('plan starts in the current week, not the next one', () {
      // The bug we shipped earlier: signing up on Tuesday meant the plan
      // started six days later on the next Monday, leaving the current
      // week empty. Plan should anchor to the most recent Monday.
      final tuesday = DateTime(2026, 4, 28); // Tuesday
      final engine = PlanEngine(now: () => tuesday);
      final plan = engine.generate(sampleProfile());
      // Most recent Monday before/on 2026-04-28 is 2026-04-27
      expect(plan.startsOn, DateTime(2026, 4, 27));
    });

    test('week 1 has at least 3 non-rest sessions', () {
      // Catches the all-rest-days bug. Even in foundation phase, a
      // 4-days-per-week profile should see Tue/Wed/Fri/Sun as run days.
      final engine = PlanEngine(now: () => DateTime(2026, 4, 28));
      final plan = engine.generate(sampleProfile());
      final week1 = plan.sessions.where((s) => s.weekNumber == 1).toList();
      expect(week1.length, 7);
      final runDays = week1
          .where((s) => s.type != SessionType.rest)
          .toList();
      expect(runDays.length >= 3, true,
          reason: 'Expected ≥3 non-rest sessions in week 1, got '
              '${runDays.length}');
    });

    test('5K plan is shorter than marathon plan', () {
      final engine = PlanEngine(now: () => DateTime(2026, 4, 28));
      final fiveK = engine.generate(sampleProfile(
        goal: GoalDistance.fiveK,
        weeksUntilRace: 12,
      ));
      final marathon = engine.generate(sampleProfile(
        goal: GoalDistance.marathon,
        weeksUntilRace: 52,
      ));
      expect(fiveK.totalWeeks < marathon.totalWeeks, true);
    });

    test('race day session matches goal distance', () {
      final engine = PlanEngine(now: () => DateTime(2026, 4, 28));
      for (final goal in GoalDistance.values) {
        final plan = engine.generate(sampleProfile(
          goal: goal,
          weeksUntilRace: goal.minWeeks + 4,
        ));
        final raceSession = plan.sessions
            .firstWhere((s) => s.type == SessionType.race);
        expect(raceSession.prescribedDistanceKm,
            closeTo(goal.km, 0.5), reason: '${goal.label} race day');
      }
    });

    test('peak long run scales with goal distance', () {
      final engine = PlanEngine(now: () => DateTime(2026, 4, 28));
      double peakLongFor(GoalDistance g) {
        final plan = engine.generate(sampleProfile(
          goal: g,
          weeksUntilRace: g.minWeeks + 8,
          daysPerWeek: 5,
        ));
        return plan.sessions
            .where((s) => s.type == SessionType.long)
            .fold<double>(0,
                (peak, s) => s.prescribedDistanceKm > peak
                    ? s.prescribedDistanceKm
                    : peak);
      }

      final fiveKPeak = peakLongFor(GoalDistance.fiveK);
      final marathonPeak = peakLongFor(GoalDistance.marathon);
      expect(marathonPeak > fiveKPeak * 2, true,
          reason: 'Marathon long should be far longer than 5K long');
    });
  });
}
