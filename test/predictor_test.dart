import 'package:flutter_test/flutter_test.dart';

import 'package:daloy/features/fitness/predictor.dart';
import 'package:daloy/features/profile/models/user_profile.dart';

UserProfile _profile({
  FitnessLevel fitness = FitnessLevel.beginner,
  double weightKg = 70,
  double heightCm = 175,
  int age = 30,
  Gender gender = Gender.male,
}) {
  final now = DateTime(2026, 1, 1);
  return UserProfile(
    id: 'test',
    name: 'T',
    ageYears: age,
    gender: gender,
    heightCm: heightCm,
    weightKg: weightKg,
    fitnessLevel: fitness,
    daysPerWeek: 4,
    goalDistance: GoalDistance.marathon,
    targetMarathonDate: now.add(const Duration(days: 365)),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  group('easyPaceSecPerKm', () {
    test('easy pace is slower than marathon pace at every VDOT band', () {
      for (final vdot in [25.0, 35.0, 45.0, 55.0, 65.0]) {
        final marathon = marathonPaceSecPerKm(vdot);
        final easy = easyPaceSecPerKm(vdot);
        expect(easy, greaterThan(marathon),
            reason: 'easy must be slower than marathon at VDOT $vdot');
      }
    });

    test('easy/marathon ratio matches Daniels (~1.135) within 1%', () {
      for (final vdot in [25.0, 35.0, 45.0, 55.0, 65.0]) {
        final marathon = marathonPaceSecPerKm(vdot);
        final easy = easyPaceSecPerKm(vdot);
        final ratio = easy / marathon;
        expect(ratio, inInclusiveRange(1.13, 1.14),
            reason: 'easy/marathon ratio off at VDOT $vdot: $ratio');
      }
    });
  });

  group('demographic VDOT', () {
    test('overweight beginner is meaningfully slower than fit beginner', () {
      // Same fitness level, different BMI. The overweight profile
      // should land at a lower VDOT due to the BMI penalty.
      final fit = estimateCurrentVdot(_profile(weightKg: 70));
      final overweight = estimateCurrentVdot(_profile(weightKg: 95));
      expect(overweight, lessThan(fit - 2),
          reason: 'BMI penalty should drop VDOT by at least 2 points');
    });

    test('higher fitness level => higher VDOT, all else equal', () {
      final none = estimateCurrentVdot(_profile(fitness: FitnessLevel.none));
      final beg =
          estimateCurrentVdot(_profile(fitness: FitnessLevel.beginner));
      final rec =
          estimateCurrentVdot(_profile(fitness: FitnessLevel.recreational));
      final inter =
          estimateCurrentVdot(_profile(fitness: FitnessLevel.intermediate));
      expect(beg, greaterThan(none));
      expect(rec, greaterThan(beg));
      expect(inter, greaterThan(rec));
    });

    test('beginner with BMI 34 lands somewhere reasonable for an obese starter',
        () {
      // Repro of the user's reported profile: 85kg / 158cm.
      final p = _profile(
        fitness: FitnessLevel.beginner,
        weightKg: 85,
        heightCm: 158,
        age: 23,
      );
      final vdot = estimateCurrentVdot(p);
      // Expected: somewhere in the low-to-mid 20s after the steeper
      // BMI penalty. Definitely not 30+ (which the old formula gave).
      expect(vdot, inInclusiveRange(22, 28),
          reason: 'obese-beginner VDOT should be tempered: got $vdot');
      // Easy pace should be slower than 8:00/km for this profile.
      expect(easyPaceSecPerKm(vdot), greaterThan(480));
    });
  });

  group('targetVdot', () {
    test('improvement caps are realistic', () {
      // 12 months of improvement with the new (lower) caps shouldn't
      // turn a couch starter into a sub-25 5K runner.
      final p = _profile(fitness: FitnessLevel.none, age: 30);
      final start = estimateCurrentVdot(p);
      final target = estimateTargetVdot(p);
      final delta = target - start;
      expect(delta, inInclusiveRange(4, 8),
          reason: '12-month improvement should be ~6 VDOT for none');
    });

    test('older athletes improve less', () {
      final young = _profile(age: 28);
      final old = _profile(age: 55);
      final youngDelta =
          estimateTargetVdot(young) - estimateCurrentVdot(young);
      final oldDelta = estimateTargetVdot(old) - estimateCurrentVdot(old);
      expect(oldDelta, lessThan(youngDelta));
    });
  });
}
