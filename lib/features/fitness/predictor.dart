import 'dart:math';

import '../profile/models/user_profile.dart';

/// Distances in meters.
const double k5km = 5000;
const double k10km = 10000;
const double kHalfMarathon = 21097.5;
const double kMarathon = 42195;

/// Estimates current VDOT (Jack Daniels VO2max proxy) from a UserProfile.
///
/// If the user provided a recent run (distance + time), VDOT is computed
/// directly from that race performance. Otherwise we fall back to a
/// demographic estimate based on fitness level, age, gender, and BMI.
double estimateCurrentVdot(UserProfile p) {
  if (p.recentRunDistanceM != null && p.recentRunDuration != null) {
    return vdotFromRace(p.recentRunDistanceM!, p.recentRunDuration!);
  }
  return _vdotFromDemographics(p);
}

/// VDOT achievable after 12 months of consistent training, assuming the user
/// follows the plan. Realistic improvement caps (the previous numbers were
/// aspirational and led to over-fast pace prescriptions in mid-plan weeks):
///   - True beginner (none): +6 VDOT achievable in a year of consistent work
///   - Beginner: +5
///   - Recreational: +3
///   - Intermediate: +2
double estimateTargetVdot(UserProfile p) {
  final current = estimateCurrentVdot(p);
  final improvement = switch (p.fitnessLevel) {
    FitnessLevel.none => 6.0,
    FitnessLevel.beginner => 5.0,
    FitnessLevel.recreational => 3.0,
    FitnessLevel.intermediate => 2.0,
  };
  // Older athletes improve less; younger athletes can stretch further.
  final ageFactor = p.ageYears > 50
      ? 0.7
      : p.ageYears > 40
          ? 0.85
          : 1.0;
  return current + improvement * ageFactor;
}

/// Daniels' VDOT from a race performance.
double vdotFromRace(double distanceM, Duration time) {
  final tMin = time.inMilliseconds / 1000.0 / 60.0;
  final vMpm = distanceM / tMin; // meters per minute
  final vo2 = -4.60 + 0.182258 * vMpm + 0.000104 * vMpm * vMpm;
  final pct = _percentMax(tMin);
  return vo2 / pct;
}

/// Inverse of [vdotFromRace]: given a VDOT and a distance, predict race time.
/// Uses binary search since there's no closed form.
Duration predictRaceTime(double vdot, double distanceM) {
  // Reasonable bounds: 1 minute to 12 hours.
  double lo = 60;
  double hi = 12 * 60 * 60;
  for (int i = 0; i < 60; i++) {
    final mid = (lo + hi) / 2;
    final tMin = mid / 60;
    final vMpm = distanceM / tMin;
    final vo2 = -4.60 + 0.182258 * vMpm + 0.000104 * vMpm * vMpm;
    final pct = _percentMax(tMin);
    final v = vo2 / pct;
    if (v > vdot) {
      // Predicted VDOT too high means the time is too fast; slow down.
      lo = mid;
    } else {
      hi = mid;
    }
  }
  return Duration(milliseconds: ((lo + hi) / 2 * 1000).round());
}

/// Daniels' easy pace as seconds per kilometer.
///
/// Easy ≈ marathon pace × 1.135 across all VDOT bands. The earlier
/// `marathon + 75 sec/km` shortcut was tuned for elite VDOTs and
/// under-slowed easy pace for slow runners — at VDOT 30, real Daniels
/// easy is ~7:53/km vs the additive formula's 7:13/km, a 40-sec/km
/// difference that pushes a beginner into tempo territory.
double easyPaceSecPerKm(double vdot) {
  return marathonPaceSecPerKm(vdot) * 1.135;
}

/// Marathon pace as seconds per kilometer.
double marathonPaceSecPerKm(double vdot) =>
    predictRaceTime(vdot, kMarathon).inSeconds / 42.195;

/// Threshold (tempo) pace as sec/km. Roughly between marathon and 10k pace.
double thresholdPaceSecPerKm(double vdot) {
  final marathon = marathonPaceSecPerKm(vdot);
  return marathon - 15; // ~15 sec/km faster than marathon pace
}

double _percentMax(double tMin) =>
    0.8 +
    0.1894393 * exp(-0.012778 * tMin) +
    0.2989558 * exp(-0.1932605 * tMin);

double _vdotFromDemographics(UserProfile p) {
  // Baseline by fitness level, anchored at a 30yo male of healthy BMI.
  // The previous bases (28/35/42/48) overstated baseline fitness for
  // someone genuinely starting out — VDOT 35 is a sub-25 5K, which is
  // not "beginner." Lower bases make demographic prescriptions more
  // honest at the expense of being optimistic about elite users
  // (who should be entering a recent race time anyway).
  double base = switch (p.fitnessLevel) {
    FitnessLevel.none => 22.0,         // can walk briskly; ~38min 5K equivalent
    FitnessLevel.beginner => 30.0,      // occasional jogger; ~28min 5K
    FitnessLevel.recreational => 40.0,  // regular runner; ~22min 5K
    FitnessLevel.intermediate => 47.0,  // sub-20 5K
  };

  // Age adjustment: VO2max declines roughly 0.5% per year after 25.
  if (p.ageYears > 25) {
    base *= 1 - 0.005 * (p.ageYears - 25);
  }

  // Gender adjustment: applies a modest reduction for female athletes due to
  // physiological VO2max differences. "Other" treated as midpoint.
  final genderFactor = switch (p.gender) {
    Gender.male => 1.0,
    Gender.female => 0.91,
    Gender.other => 0.955,
  };
  base *= genderFactor;

  // BMI penalty: above 27 the runner carries excess cardiovascular load.
  // Steeper than before — 2%/point capped at 13 points (BMI 40+) gives
  // up to a 26% reduction, which better reflects how much VO2max
  // performance is suppressed by carrying significant excess weight.
  // Previous 1.5%/point capped at 8 only allowed -12%, far too gentle
  // for class-I and class-II obesity.
  final bmi = p.bmi;
  if (bmi > 27) {
    base *= 1 - 0.02 * (bmi - 27).clamp(0, 13);
  } else if (bmi < 18.5) {
    base *= 0.97;
  }

  return base;
}
