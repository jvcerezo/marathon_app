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
/// follows the plan. Improvement caps:
///   - Total beginner (FitnessLevel.none): +10 to +15 VDOT possible
///   - Recreational: +5 to +8
///   - Intermediate: +2 to +4
/// We pick the conservative end so predicted goal times feel attainable.
double estimateTargetVdot(UserProfile p) {
  final current = estimateCurrentVdot(p);
  final improvement = switch (p.fitnessLevel) {
    FitnessLevel.none => 10.0,
    FitnessLevel.beginner => 8.0,
    FitnessLevel.recreational => 5.0,
    FitnessLevel.intermediate => 3.0,
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
/// Easy = ~70% VO2max equivalent pace.
double easyPaceSecPerKm(double vdot) {
  // Approximation: easy pace VDOT is ~10 lower than race VDOT for marathons.
  // Empirically: easy ~85-90s slower than marathon pace per km.
  final marathonPace = predictRaceTime(vdot, kMarathon).inSeconds / 42.195;
  return marathonPace + 75; // ~75 sec/km slower than marathon pace
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
  double base = switch (p.fitnessLevel) {
    FitnessLevel.none => 28.0,
    FitnessLevel.beginner => 35.0,
    FitnessLevel.recreational => 42.0,
    FitnessLevel.intermediate => 48.0,
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

  // BMI penalty: above 27 the runner carries excess load. Below 18.5,
  // potentially under-fueled — small penalty too.
  final bmi = p.bmi;
  if (bmi > 27) {
    base *= 1 - 0.015 * (bmi - 27).clamp(0, 8);
  } else if (bmi < 18.5) {
    base *= 0.97;
  }

  return base;
}
