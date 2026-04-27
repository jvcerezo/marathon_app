import 'package:uuid/uuid.dart';

import '../../fitness/predictor.dart';
import '../../profile/models/user_profile.dart';
import '../models/plan_session.dart';
import '../models/training_plan.dart';

/// Generates a 52-week couch-to-marathon training plan.
///
/// Phases:
///   1. Foundation (weeks 1-12)  — build aerobic base, no quality work
///   2. Base       (weeks 13-24) — introduce easy tempo, longer long runs
///   3. Build      (weeks 25-36) — tempo + intervals, peak long runs near 26 km
///   4. Peak       (weeks 37-48) — marathon-pace work, long runs to 32 km
///   5. Taper      (weeks 49-52) — reduce volume, sharpen, race
class PlanEngine {
  final Uuid _uuid;
  final DateTime Function() _now;

  PlanEngine({Uuid? uuid, DateTime Function()? now})
      : _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  TrainingPlan generate(UserProfile profile) {
    final startVdot = estimateCurrentVdot(profile);
    final targetVdot = estimateTargetVdot(profile);
    final easyPaceStart = easyPaceSecPerKm(startVdot);
    final easyPaceEnd = easyPaceSecPerKm(targetVdot);
    final tempoPaceEnd = thresholdPaceSecPerKm(targetVdot);
    final marathonPaceEnd = marathonPaceSecPerKm(targetVdot);

    // Anchor the plan to the next Monday on/after now.
    final today = DateTime(_now().year, _now().month, _now().day);
    final daysUntilMonday = (DateTime.monday - today.weekday + 7) % 7;
    final startsOn = today.add(Duration(days: daysUntilMonday));

    final fitnessFactor = _fitnessFactor(profile.fitnessLevel);
    final daysPerWeek = profile.daysPerWeek.clamp(3, 6);
    final planId = _uuid.v4();
    final sessions = <PlanSession>[];

    for (int week = 1; week <= 52; week++) {
      final weekStart = startsOn.add(Duration(days: (week - 1) * 7));
      final phase = _phaseFor(week);
      final isCutback = week % 4 == 0 && phase != _Phase.taper;

      final weeklyKm = _weeklyKm(week, phase, isCutback) * fitnessFactor;
      final longKm = _longRunKm(week, phase, isCutback) * fitnessFactor;

      // Pace progression: linearly interpolate easy pace from start to end VDOT.
      final progress = (week - 1) / 51.0;
      final easyPace = _lerp(easyPaceStart, easyPaceEnd, progress);
      final tempoPace = _lerp(easyPaceStart - 30, tempoPaceEnd, progress);
      final marathonPace = _lerp(easyPaceStart - 15, marathonPaceEnd, progress);

      final hasQuality = phase != _Phase.foundation && !isCutback &&
          phase != _Phase.taper;
      final qualityType = _qualityTypeFor(week, phase);

      // Distance budget after long + (optional) quality.
      double qualityKm = 0;
      if (hasQuality) {
        qualityKm = switch (qualityType) {
          SessionType.tempo => 6 + (week / 12).clamp(0, 4),
          SessionType.intervals => 5 + (week / 16).clamp(0, 3),
          _ => 0,
        };
      }
      final remainingKm = (weeklyKm - longKm - qualityKm).clamp(0, 1000);
      final easyDayCount = daysPerWeek - 1 - (hasQuality ? 1 : 0);
      final easyKmEach = easyDayCount > 0 ? remainingKm / easyDayCount : 0.0;

      // Layout days across the week: long on Sunday, quality on Wednesday,
      // easy on remaining selected days.
      final layout = _weekLayout(daysPerWeek);
      for (int day = 1; day <= 7; day++) {
        final date = weekStart.add(Duration(days: day - 1));
        final slot = layout[day]!;
        late final PlanSession session;
        switch (slot) {
          case _Slot.rest:
            session = PlanSession(
              id: _uuid.v4(),
              planId: planId,
              scheduledDate: date,
              weekNumber: week,
              dayOfWeek: day,
              type: SessionType.rest,
              prescribedDistanceKm: 0,
              status: SessionStatus.rest,
            );
          case _Slot.long:
            session = PlanSession(
              id: _uuid.v4(),
              planId: planId,
              scheduledDate: date,
              weekNumber: week,
              dayOfWeek: day,
              type: SessionType.long,
              prescribedDistanceKm: _round(longKm),
              prescribedPaceSecPerKm: easyPace,
              status: SessionStatus.scheduled,
              notes: phase == _Phase.peak && week >= 40
                  ? 'Practice race-day fueling and pace.'
                  : null,
            );
          case _Slot.quality:
            if (!hasQuality) {
              session = PlanSession(
                id: _uuid.v4(),
                planId: planId,
                scheduledDate: date,
                weekNumber: week,
                dayOfWeek: day,
                type: SessionType.easy,
                prescribedDistanceKm: _round(easyKmEach),
                prescribedPaceSecPerKm: easyPace,
                status: SessionStatus.scheduled,
              );
            } else {
              session = PlanSession(
                id: _uuid.v4(),
                planId: planId,
                scheduledDate: date,
                weekNumber: week,
                dayOfWeek: day,
                type: qualityType,
                prescribedDistanceKm: _round(qualityKm),
                prescribedPaceSecPerKm: qualityType == SessionType.intervals
                    ? tempoPace - 20
                    : phase == _Phase.peak
                        ? marathonPace
                        : tempoPace,
                status: SessionStatus.scheduled,
                notes: qualityType == SessionType.intervals
                    ? 'Warm up, then 4-6x 800m at target pace, jog recovery.'
                    : 'Sustained effort at the prescribed pace.',
              );
            }
          case _Slot.easy:
            session = PlanSession(
              id: _uuid.v4(),
              planId: planId,
              scheduledDate: date,
              weekNumber: week,
              dayOfWeek: day,
              type: SessionType.easy,
              prescribedDistanceKm: _round(easyKmEach),
              prescribedPaceSecPerKm: easyPace,
              status: SessionStatus.scheduled,
            );
        }
        sessions.add(session);
      }
    }

    // Replace the final Sunday with the marathon itself.
    if (sessions.isNotEmpty) {
      final last = sessions.lastIndexWhere((s) => s.dayOfWeek == 7);
      if (last >= 0) {
        final s = sessions[last];
        sessions[last] = PlanSession(
          id: s.id,
          planId: s.planId,
          scheduledDate: s.scheduledDate,
          weekNumber: s.weekNumber,
          dayOfWeek: s.dayOfWeek,
          type: SessionType.race,
          prescribedDistanceKm: 42.2,
          prescribedPaceSecPerKm: marathonPaceSecPerKm(targetVdot),
          status: SessionStatus.scheduled,
          notes: 'Race day. You earned this.',
        );
      }
    }

    final marathonDate = sessions.last.scheduledDate;
    return TrainingPlan(
      id: planId,
      userId: profile.id,
      startsOn: startsOn,
      targetMarathonDate: marathonDate,
      totalWeeks: 52,
      startVdot: startVdot,
      targetVdot: targetVdot,
      sessions: sessions,
    );
  }

  double _fitnessFactor(FitnessLevel level) => switch (level) {
        FitnessLevel.none => 0.65,
        FitnessLevel.beginner => 0.8,
        FitnessLevel.recreational => 1.0,
        FitnessLevel.intermediate => 1.15,
      };

  _Phase _phaseFor(int week) {
    if (week <= 12) return _Phase.foundation;
    if (week <= 24) return _Phase.base;
    if (week <= 36) return _Phase.build;
    if (week <= 48) return _Phase.peak;
    return _Phase.taper;
  }

  /// Total target weekly km before fitness scaling.
  double _weeklyKm(int week, _Phase phase, bool isCutback) {
    double base = switch (phase) {
      _Phase.foundation => 12 + (week - 1) * 1.5, // 12 → 28
      _Phase.base => 28 + (week - 13) * 1.4, // 28 → 44
      _Phase.build => 44 + (week - 25) * 1.0, // 44 → 55
      _Phase.peak => 55 + (week - 37) * 0.8, // 55 → 64
      _Phase.taper => switch (week) {
          49 => 50,
          50 => 35,
          51 => 22,
          52 => 50, // race week incl. 42km race day, so total still high
          _ => 30,
        },
    };
    if (isCutback) base *= 0.75;
    return base;
  }

  double _longRunKm(int week, _Phase phase, bool isCutback) {
    double base = switch (phase) {
      _Phase.foundation => 4 + (week - 1) * 0.6, // 4 → 11
      _Phase.base => 10 + (week - 13) * 0.7, // 10 → 18
      _Phase.build => 16 + (week - 25) * 0.9, // 16 → 26
      _Phase.peak => 24 + (week - 37) * 0.7, // 24 → 32
      _Phase.taper => switch (week) {
          49 => 26,
          50 => 18,
          51 => 12,
          52 => 42.2, // race
          _ => 12,
        },
    };
    if (isCutback) base *= 0.7;
    return base;
  }

  SessionType _qualityTypeFor(int week, _Phase phase) {
    if (phase == _Phase.base) return SessionType.tempo;
    if (phase == _Phase.build) {
      return week.isEven ? SessionType.intervals : SessionType.tempo;
    }
    if (phase == _Phase.peak) return SessionType.tempo;
    return SessionType.easy;
  }

  Map<int, _Slot> _weekLayout(int daysPerWeek) {
    // 1=Mon, 7=Sun
    final layout = <int, _Slot>{
      for (int d = 1; d <= 7; d++) d: _Slot.rest,
    };
    layout[7] = _Slot.long; // Sunday long run
    if (daysPerWeek >= 4) layout[3] = _Slot.quality; // Wed
    final easyDays = switch (daysPerWeek) {
      3 => [2, 4], // Tue, Thu
      4 => [2, 5], // Tue, Fri
      5 => [2, 4, 6], // Tue, Thu, Sat
      6 => [2, 4, 5, 6], // Tue, Thu, Fri, Sat
      _ => [2, 4],
    };
    for (final d in easyDays) {
      layout[d] = _Slot.easy;
    }
    return layout;
  }

  double _round(double km) {
    if (km <= 0) return 0;
    return (km * 2).round() / 2; // round to nearest 0.5 km
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

enum _Phase { foundation, base, build, peak, taper }

enum _Slot { rest, easy, long, quality }
