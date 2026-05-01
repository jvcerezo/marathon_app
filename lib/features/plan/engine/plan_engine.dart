import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../fitness/predictor.dart';
import '../../profile/models/user_profile.dart';
import '../models/plan_session.dart';
import '../models/training_plan.dart';

/// Generates a training plan whose length matches the user's race date,
/// with phase distribution proportional to the total weeks and peak
/// volumes tuned to the chosen goal distance (5K through Marathon).
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
    final goalPaceEnd = predictRaceTime(targetVdot, profile.goalDistance.meters)
            .inSeconds /
        (profile.goalDistance.km);

    // Anchor the plan to the most recent Monday (could be today). This
    // guarantees the user is inside week 1 immediately after onboarding,
    // instead of waiting up to 6 days for "next Monday" to arrive.
    final today = DateTime(_now().year, _now().month, _now().day);
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    final startsOn = today.subtract(Duration(days: daysSinceMonday));

    final raceDate = _alignRaceDateToSunday(profile.targetMarathonDate);
    final daysToRace = raceDate.difference(startsOn).inDays;
    final rawWeeks = (daysToRace + 1) / 7;
    final totalWeeks = rawWeeks
        .ceil()
        .clamp(profile.goalDistance.minWeeks, profile.goalDistance.maxWeeks);

    final boundaries = _phaseBoundaries(totalWeeks);
    final peakWeeklyKm = _peakWeeklyKm(profile.goalDistance);
    final peakLongKm = _peakLongKm(profile.goalDistance);
    final raceDistanceKm = profile.goalDistance.km;

    final fitnessFactor = _fitnessFactor(profile.fitnessLevel);
    final daysPerWeek = profile.daysPerWeek.clamp(3, 6);
    final planId = _uuid.v4();
    final sessions = <PlanSession>[];

    for (int week = 1; week <= totalWeeks; week++) {
      final weekStart = startsOn.add(Duration(days: (week - 1) * 7));
      final phase = _phaseFor(week, boundaries);
      final isCutback = _isCutback(week, totalWeeks, phase, boundaries);

      double weeklyKm = _weeklyKmAt(
            week: week,
            totalWeeks: totalWeeks,
            phase: phase,
            boundaries: boundaries,
            peakKm: peakWeeklyKm,
          ) *
          fitnessFactor;
      double longKm = _longKmAt(
            week: week,
            totalWeeks: totalWeeks,
            phase: phase,
            boundaries: boundaries,
            peakLong: peakLongKm,
            raceKm: raceDistanceKm,
          ) *
          fitnessFactor;
      if (isCutback) {
        weeklyKm *= 0.75;
        longKm *= 0.75;
      }

      // Pace progression: linearly interpolate easy + tempo from start to
      // end VDOT across the plan.
      final progress = (week - 1) / max(1, totalWeeks - 1);
      final easyPace = _lerp(easyPaceStart, easyPaceEnd, progress);
      final tempoPace = _lerp(easyPaceStart - 30, tempoPaceEnd, progress);
      final goalPace = _lerp(easyPaceStart - 15, goalPaceEnd, progress);

      final hasQuality =
          phase != _Phase.foundation && phase != _Phase.taper && !isCutback;
      final qualityType = _qualityTypeFor(week, phase);

      double qualityKm = 0;
      if (hasQuality) {
        qualityKm = switch (qualityType) {
          SessionType.tempo =>
            (4 + week.toDouble() * 0.25).clamp(4, 10).toDouble(),
          SessionType.intervals =>
            (4 + week.toDouble() * 0.18).clamp(4, 8).toDouble(),
          _ => 0,
        };
      }

      final remainingKm = (weeklyKm - longKm - qualityKm).clamp(0, 1000);
      final easyDayCount = daysPerWeek - 1 - (hasQuality ? 1 : 0);
      final easyKmEach =
          easyDayCount > 0 ? remainingKm / easyDayCount : 0.0;

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
              notes: phase == _Phase.peak
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
                        ? goalPace
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

    // Replace the final Sunday with the actual race.
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
          prescribedDistanceKm: _round(raceDistanceKm),
          prescribedPaceSecPerKm: goalPaceEnd,
          status: SessionStatus.scheduled,
          notes: 'Race day. You earned this.',
        );
      }
    }

    return TrainingPlan(
      id: planId,
      userId: profile.id,
      startsOn: startsOn,
      targetMarathonDate: sessions.last.scheduledDate,
      totalWeeks: totalWeeks,
      startVdot: startVdot,
      targetVdot: targetVdot,
      type: PlanType.race,
      sessions: sessions,
    );
  }

  /// Open-ended **progressive** plan for users who don't have a target
  /// race day but want to keep getting better. Phased like the race
  /// plan (foundation → build → consolidate) but without a taper —
  /// volume ramps to a sustained peak, quality work fades in, and
  /// every fourth week is a 25% cutback for recovery.
  ///
  /// The plan ends with a "rest week" rather than a race session.
  /// Default 24 weeks; the user can regenerate from Settings to keep
  /// progressing.
  TrainingPlan generateProgressive(
    UserProfile profile, {
    int weeks = 24,
  }) {
    final startVdot = estimateCurrentVdot(profile);
    final targetVdot = estimateTargetVdot(profile);
    final easyPaceStart = easyPaceSecPerKm(startVdot);
    final easyPaceEnd = easyPaceSecPerKm(targetVdot);
    final tempoPaceEnd = thresholdPaceSecPerKm(targetVdot);

    final today = DateTime(_now().year, _now().month, _now().day);
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    final startsOn = today.subtract(Duration(days: daysSinceMonday));

    final fitnessFactor = _fitnessFactor(profile.fitnessLevel);
    final daysPerWeek = profile.daysPerWeek.clamp(3, 6);
    final layout = _weekLayout(daysPerWeek);
    final peakKm = _peakWeeklyKm(profile.goalDistance);
    final peakLong = _peakLongKm(profile.goalDistance);

    // Phase splits for a progressive plan: lighter foundation than the
    // race version, longer build, no taper.
    final foundationEnd = (weeks * 0.30).round().clamp(2, weeks);
    final buildEnd = (weeks * 0.80).round().clamp(foundationEnd + 1, weeks);

    final planId = _uuid.v4();
    final sessions = <PlanSession>[];

    for (int week = 1; week <= weeks; week++) {
      final weekStart = startsOn.add(Duration(days: (week - 1) * 7));
      final isCutback =
          week % 4 == 0 && week < weeks; // skip cutback on the final week

      // Volume curve: 12 km/wk → 0.55*peak (foundation) → 0.85*peak
      // (build) → peak (consolidate). All scaled by fitnessFactor and
      // optionally cut back 25% on cutback weeks.
      double weeklyKm;
      double longKm;
      if (week <= foundationEnd) {
        final t = (week - 1) / (foundationEnd - 1).clamp(1, weeks).toDouble();
        weeklyKm = _lerp(12, peakKm * 0.55, t);
        longKm = _lerp(4, peakLong * 0.40, t);
      } else if (week <= buildEnd) {
        final t = (week - foundationEnd - 1) /
            (buildEnd - foundationEnd).clamp(1, weeks).toDouble();
        weeklyKm = _lerp(peakKm * 0.55, peakKm * 0.85, t.clamp(0, 1));
        longKm = _lerp(peakLong * 0.40, peakLong * 0.75, t.clamp(0, 1));
      } else {
        final t = (week - buildEnd - 1) /
            (weeks - buildEnd).clamp(1, weeks).toDouble();
        weeklyKm = _lerp(peakKm * 0.85, peakKm, t.clamp(0, 1));
        longKm = _lerp(peakLong * 0.75, peakLong, t.clamp(0, 1));
      }
      weeklyKm *= fitnessFactor;
      longKm *= fitnessFactor;
      if (isCutback) {
        weeklyKm *= 0.75;
        longKm *= 0.75;
      }

      final progress = (week - 1) / (weeks - 1).clamp(1, weeks).toDouble();
      final easyPace = _lerp(easyPaceStart, easyPaceEnd, progress);
      final tempoPace =
          _lerp(easyPaceStart - 30, tempoPaceEnd, progress);

      // Quality only in build + consolidate phases, not on cutback weeks.
      final hasQuality = week > foundationEnd && !isCutback;
      final qualityType =
          hasQuality && week.isEven ? SessionType.intervals : SessionType.tempo;
      final qualityKm = !hasQuality
          ? 0.0
          : qualityType == SessionType.tempo
              ? (4 + (week - foundationEnd) * 0.25).clamp(4, 9).toDouble()
              : (4 + (week - foundationEnd) * 0.18).clamp(4, 7).toDouble();

      final remainingKm =
          (weeklyKm - longKm - qualityKm).clamp(0, 1000).toDouble();
      final easyDayCount = daysPerWeek - 1 - (hasQuality ? 1 : 0);
      final easyKmEach =
          easyDayCount > 0 ? remainingKm / easyDayCount : 0.0;

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
                    : tempoPace,
                status: SessionStatus.scheduled,
                notes: qualityType == SessionType.intervals
                    ? 'Warm up, then 4-6x 800m at target pace, jog recovery.'
                    : 'Sustained tempo effort at the prescribed pace.',
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

    return TrainingPlan(
      id: planId,
      userId: profile.id,
      startsOn: startsOn,
      targetMarathonDate: sessions.last.scheduledDate,
      totalWeeks: weeks,
      startVdot: startVdot,
      targetVdot: targetVdot,
      type: PlanType.maintenance,
      sessions: sessions,
    );
  }

  /// Open-ended maintenance plan after the user finishes a race or wants
  /// to coast for a while. No taper, no quality, no peak — just a stable
  /// weekly template that loops for `weeks` weeks.
  ///
  /// Volume is anchored to ~65% of the user's prior peak weekly km, which
  /// is enough to hold fitness without the fatigue cost of training to
  /// race again.
  TrainingPlan generateMaintenance(
    UserProfile profile, {
    int weeks = 16,
  }) {
    final startVdot = estimateCurrentVdot(profile);
    final easyPace = easyPaceSecPerKm(startVdot);

    final today = DateTime(_now().year, _now().month, _now().day);
    final daysSinceMonday = (today.weekday - DateTime.monday) % 7;
    final startsOn = today.subtract(Duration(days: daysSinceMonday));

    final fitnessFactor = _fitnessFactor(profile.fitnessLevel);
    final daysPerWeek = profile.daysPerWeek.clamp(3, 6);
    final layout = _weekLayout(daysPerWeek);

    final maintainKm = _peakWeeklyKm(profile.goalDistance) * 0.65 * fitnessFactor;
    final maintainLong = _peakLongKm(profile.goalDistance) * 0.55 * fitnessFactor;
    final easyDayCount = daysPerWeek - 1;
    final easyKmEach =
        easyDayCount > 0 ? (maintainKm - maintainLong) / easyDayCount : 0.0;

    final planId = _uuid.v4();
    final sessions = <PlanSession>[];

    for (int week = 1; week <= weeks; week++) {
      final weekStart = startsOn.add(Duration(days: (week - 1) * 7));
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
              prescribedDistanceKm: _round(maintainLong),
              prescribedPaceSecPerKm: easyPace,
              status: SessionStatus.scheduled,
            );
          case _Slot.quality:
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

    return TrainingPlan(
      id: planId,
      userId: profile.id,
      startsOn: startsOn,
      targetMarathonDate: sessions.last.scheduledDate,
      totalWeeks: weeks,
      startVdot: startVdot,
      targetVdot: startVdot,
      type: PlanType.maintenance,
      sessions: sessions,
    );
  }

  // ============== HELPERS ==============

  /// Snap the user-provided race date to the Sunday of its week so the
  /// taper week ends cleanly. Sunday is the canonical race day.
  DateTime _alignRaceDateToSunday(DateTime raceDate) {
    final d = DateTime(raceDate.year, raceDate.month, raceDate.day);
    final daysToSunday = (DateTime.sunday - d.weekday + 7) % 7;
    return d.add(Duration(days: daysToSunday));
  }

  _Boundaries _phaseBoundaries(int totalWeeks) {
    // Foundation 25%, Base 25%, Build 25%, Peak 18%, Taper 7%
    int clampMonotonic(int v, int prev) {
      if (v < prev) return prev;
      if (v > totalWeeks) return totalWeeks;
      return v;
    }

    final foundationEnd = max(1, (totalWeeks * 0.25).round());
    final baseEnd =
        clampMonotonic((totalWeeks * 0.50).round(), foundationEnd);
    final buildEnd = clampMonotonic((totalWeeks * 0.75).round(), baseEnd);
    final peakEnd = clampMonotonic((totalWeeks * 0.93).round(), buildEnd);
    return _Boundaries(
      foundationEnd: foundationEnd,
      baseEnd: baseEnd,
      buildEnd: buildEnd,
      peakEnd: peakEnd,
    );
  }

  _Phase _phaseFor(int week, _Boundaries b) {
    if (week <= b.foundationEnd) return _Phase.foundation;
    if (week <= b.baseEnd) return _Phase.base;
    if (week <= b.buildEnd) return _Phase.build;
    if (week <= b.peakEnd) return _Phase.peak;
    return _Phase.taper;
  }

  bool _isCutback(int week, int totalWeeks, _Phase phase, _Boundaries b) {
    if (phase == _Phase.taper) return false;
    if (totalWeeks - week <= 2) return false; // never cut back inside taper
    // Every 4th week within foundation/base/build/peak.
    return week % 4 == 0;
  }

  /// Peak weekly km the engine ramps toward, by goal distance. These are
  /// "well-prepared" peaks — the fitness factor scales them down for
  /// beginner profiles.
  double _peakWeeklyKm(GoalDistance g) => switch (g) {
        GoalDistance.fiveK => 35,
        GoalDistance.tenK => 45,
        GoalDistance.halfMarathon => 55,
        GoalDistance.marathon => 65,
      };

  /// Peak long-run distance, by goal distance. A 5K runner's longest
  /// run is ~10 km; a marathoner peaks around 32 km.
  double _peakLongKm(GoalDistance g) => switch (g) {
        GoalDistance.fiveK => 10,
        GoalDistance.tenK => 16,
        GoalDistance.halfMarathon => 22,
        GoalDistance.marathon => 32,
      };

  /// Weekly km at week N. Ramps from 12 km in week 1 toward `peakKm`
  /// across foundation -> base -> build -> peak, then tapers down.
  double _weeklyKmAt({
    required int week,
    required int totalWeeks,
    required _Phase phase,
    required _Boundaries boundaries,
    required double peakKm,
  }) {
    const startKm = 12.0;
    switch (phase) {
      case _Phase.foundation:
        // 12 -> 0.45 * peak
        final span = boundaries.foundationEnd;
        final t = span <= 1 ? 1.0 : (week - 1) / (span - 1);
        return _lerp(startKm, peakKm * 0.45, t);
      case _Phase.base:
        final span = boundaries.baseEnd - boundaries.foundationEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.foundationEnd - 1) / max(1, span);
        return _lerp(peakKm * 0.45, peakKm * 0.70, t.clamp(0, 1).toDouble());
      case _Phase.build:
        final span = boundaries.buildEnd - boundaries.baseEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.baseEnd - 1) / max(1, span);
        return _lerp(peakKm * 0.70, peakKm * 0.90, t.clamp(0, 1).toDouble());
      case _Phase.peak:
        final span = boundaries.peakEnd - boundaries.buildEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.buildEnd - 1) / max(1, span);
        return _lerp(peakKm * 0.90, peakKm, t.clamp(0, 1).toDouble());
      case _Phase.taper:
        final weeksLeft = totalWeeks - week;
        if (weeksLeft >= 2) return peakKm * 0.65;
        if (weeksLeft >= 1) return peakKm * 0.45;
        return peakKm * 0.40; // race week (raceday km dominates)
    }
  }

  /// Long run km at week N. Ramps from 4 km to `peakLong`, with the very
  /// last week's "long" being the race itself (handled by the caller).
  double _longKmAt({
    required int week,
    required int totalWeeks,
    required _Phase phase,
    required _Boundaries boundaries,
    required double peakLong,
    required double raceKm,
  }) {
    const startLong = 4.0;
    switch (phase) {
      case _Phase.foundation:
        final span = boundaries.foundationEnd;
        final t = span <= 1 ? 1.0 : (week - 1) / (span - 1);
        return _lerp(startLong, peakLong * 0.40, t);
      case _Phase.base:
        final span = boundaries.baseEnd - boundaries.foundationEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.foundationEnd - 1) / max(1, span);
        return _lerp(peakLong * 0.40, peakLong * 0.65, t.clamp(0, 1).toDouble());
      case _Phase.build:
        final span = boundaries.buildEnd - boundaries.baseEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.baseEnd - 1) / max(1, span);
        return _lerp(peakLong * 0.65, peakLong * 0.85, t.clamp(0, 1).toDouble());
      case _Phase.peak:
        final span = boundaries.peakEnd - boundaries.buildEnd;
        final t = span <= 0
            ? 1.0
            : (week - boundaries.buildEnd - 1) / max(1, span);
        return _lerp(peakLong * 0.85, peakLong, t.clamp(0, 1).toDouble());
      case _Phase.taper:
        final weeksLeft = totalWeeks - week;
        if (weeksLeft >= 2) return peakLong * 0.60;
        if (weeksLeft >= 1) return peakLong * 0.40;
        return raceKm; // race day distance (will be replaced by race session)
    }
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
    final layout = <int, _Slot>{
      for (int d = 1; d <= 7; d++) d: _Slot.rest,
    };
    layout[7] = _Slot.long;
    if (daysPerWeek >= 4) layout[3] = _Slot.quality;
    final easyDays = switch (daysPerWeek) {
      3 => [2, 4],
      4 => [2, 5],
      5 => [2, 4, 6],
      6 => [2, 4, 5, 6],
      _ => [2, 4],
    };
    for (final d in easyDays) {
      layout[d] = _Slot.easy;
    }
    return layout;
  }

  double _fitnessFactor(FitnessLevel level) => switch (level) {
        FitnessLevel.none => 0.65,
        FitnessLevel.beginner => 0.8,
        FitnessLevel.recreational => 1.0,
        FitnessLevel.intermediate => 1.15,
      };

  double _round(double km) {
    if (km <= 0) return 0;
    return (km * 2).round() / 2;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;
}

class _Boundaries {
  final int foundationEnd;
  final int baseEnd;
  final int buildEnd;
  final int peakEnd;

  const _Boundaries({
    required this.foundationEnd,
    required this.baseEnd,
    required this.buildEnd,
    required this.peakEnd,
  });
}

enum _Phase { foundation, base, build, peak, taper }

enum _Slot { rest, easy, long, quality }
