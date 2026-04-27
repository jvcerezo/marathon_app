import '../plan/models/plan_session.dart';
import '../plan/repository/plan_repository.dart';
import '../runs/models/completed_run.dart';
import '../runs/repository/runs_repository.dart';

/// Matches a completed run to today's scheduled session and updates the
/// session's status (hit, partial, missed).
class AdherenceService {
  final PlanRepository _plans;
  final RunsRepository _runs;

  static const double _distanceTolerance = 0.15; // ±15%
  static const double _partialThreshold = 0.6; // less than 60% = miss

  AdherenceService(this._plans, this._runs);

  Future<MatchResult?> matchRun(CompletedRun run, {String? planId}) async {
    final activePlanId = planId ?? (await _plans.active())?.id;
    if (activePlanId == null) return null;

    final session = await _plans.sessionForDate(activePlanId, run.startedAt);
    if (session == null) return null;
    if (session.type == SessionType.rest) return null;

    final actualKm = run.distanceM / 1000.0;
    final ratio = session.prescribedDistanceKm > 0
        ? actualKm / session.prescribedDistanceKm
        : 1.0;

    final SessionStatus newStatus;
    if (ratio >= 1 - _distanceTolerance && ratio <= 1 + _distanceTolerance) {
      newStatus = SessionStatus.hit;
    } else if (ratio < _partialThreshold) {
      newStatus = SessionStatus.missed;
    } else {
      newStatus = SessionStatus.partial;
    }

    await _plans.updateSessionStatus(
      session.id,
      status: newStatus,
      matchedRunId: run.id,
    );
    await _runs.linkToSession(run.id, session.id);

    return MatchResult(session: session, status: newStatus, ratio: ratio);
  }

  /// Mark missed sessions for any past dates with status == scheduled.
  Future<int> sweepMissedSessions(String planId) async {
    final today = DateTime.now();
    final cutoff = DateTime(today.year, today.month, today.day);
    final past = await _plans.sessionsInRange(
      planId,
      DateTime(2000),
      cutoff,
    );
    int swept = 0;
    for (final s in past) {
      if (s.status == SessionStatus.scheduled && s.type != SessionType.rest) {
        await _plans.updateSessionStatus(s.id, status: SessionStatus.missed);
        swept++;
      }
    }
    return swept;
  }
}

class MatchResult {
  final PlanSession session;
  final SessionStatus status;
  final double ratio;

  const MatchResult({
    required this.session,
    required this.status,
    required this.ratio,
  });
}
