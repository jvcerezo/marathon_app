import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../models/plan_session.dart';
import '../models/training_plan.dart';

class PlanRepository {
  final AppDatabase _db;
  PlanRepository(this._db);

  Future<TrainingPlan?> active() async {
    final planRows = await (_db.select(_db.plans)
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)])
          ..limit(1))
        .get();
    if (planRows.isEmpty) return null;
    final plan = planRows.first;
    final sessions = await (_db.select(_db.planSessionsTable)
          ..where((s) => s.planId.equals(plan.id))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .get();

    return TrainingPlan(
      id: plan.id,
      userId: plan.userId,
      startsOn: plan.startsOn,
      targetMarathonDate: plan.targetMarathonDate,
      totalWeeks: plan.totalWeeks,
      startVdot: plan.startVdot,
      targetVdot: plan.targetVdot,
      type: PlanType.values.firstWhere(
        (t) => t.name == plan.planType,
        orElse: () => PlanType.race,
      ),
      sessions: sessions.map(_sessionToDomain).toList(),
    );
  }

  Future<void> save(TrainingPlan plan) async {
    await _db.transaction(() async {
      await _db.into(_db.plans).insertOnConflictUpdate(
            PlansCompanion.insert(
              id: plan.id,
              userId: plan.userId,
              startsOn: plan.startsOn,
              targetMarathonDate: plan.targetMarathonDate,
              totalWeeks: plan.totalWeeks,
              startVdot: plan.startVdot,
              targetVdot: plan.targetVdot,
              planType: Value(plan.type.name),
              createdAt: DateTime.now(),
            ),
          );
      await _db.batch((b) {
        b.insertAllOnConflictUpdate(
          _db.planSessionsTable,
          plan.sessions.map(_sessionToCompanion).toList(),
        );
      });
    });
  }

  Future<PlanSession?> sessionForDate(String planId, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final row = await (_db.select(_db.planSessionsTable)
          ..where((s) =>
              s.planId.equals(planId) &
              s.scheduledDate.isBiggerOrEqualValue(start) &
              s.scheduledDate.isSmallerThanValue(end))
          ..limit(1))
        .getSingleOrNull();
    return row == null ? null : _sessionToDomain(row);
  }

  Future<List<PlanSession>> sessionsInRange(
    String planId,
    DateTime from,
    DateTime to,
  ) async {
    final rows = await (_db.select(_db.planSessionsTable)
          ..where((s) =>
              s.planId.equals(planId) &
              s.scheduledDate.isBiggerOrEqualValue(from) &
              s.scheduledDate.isSmallerThanValue(to))
          ..orderBy([(s) => OrderingTerm.asc(s.scheduledDate)]))
        .get();
    return rows.map(_sessionToDomain).toList();
  }

  /// Wipes the active plan (and its sessions). Used by "Take a break".
  Future<void> clearActive() async {
    await _db.transaction(() async {
      await _db.delete(_db.planSessionsTable).go();
      await _db.delete(_db.plans).go();
    });
  }

  Future<void> updateSessionStatus(
    String sessionId, {
    required SessionStatus status,
    String? matchedRunId,
  }) async {
    await (_db.update(_db.planSessionsTable)
          ..where((s) => s.id.equals(sessionId)))
        .write(
      PlanSessionsTableCompanion(
        status: Value(status.name),
        matchedRunId: Value(matchedRunId),
      ),
    );
  }

  PlanSession _sessionToDomain(PlanSessionRow row) => PlanSession(
        id: row.id,
        planId: row.planId,
        scheduledDate: row.scheduledDate,
        weekNumber: row.weekNumber,
        dayOfWeek: row.dayOfWeek,
        type: SessionType.values.firstWhere((t) => t.name == row.type),
        prescribedDistanceKm: row.prescribedDistanceKm,
        prescribedPaceSecPerKm: row.prescribedPaceSecPerKm,
        notes: row.notes,
        status: SessionStatus.values.firstWhere((s) => s.name == row.status),
        matchedRunId: row.matchedRunId,
      );

  PlanSessionsTableCompanion _sessionToCompanion(PlanSession s) =>
      PlanSessionsTableCompanion.insert(
        id: s.id,
        planId: s.planId,
        scheduledDate: s.scheduledDate,
        weekNumber: s.weekNumber,
        dayOfWeek: s.dayOfWeek,
        type: s.type.name,
        prescribedDistanceKm: s.prescribedDistanceKm,
        prescribedPaceSecPerKm: Value(s.prescribedPaceSecPerKm),
        notes: Value(s.notes),
        status: s.status.name,
        matchedRunId: Value(s.matchedRunId),
      );
}
