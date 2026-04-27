import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../recording/models/run_sample.dart';
import '../models/completed_run.dart';

class RunsRepository {
  final AppDatabase _db;
  RunsRepository(this._db);

  Future<String> createRun({
    required String id,
    required DateTime startedAt,
  }) async {
    await _db.into(_db.runs).insert(
          RunsCompanion.insert(
            id: id,
            startedAt: startedAt,
          ),
        );
    return id;
  }

  Future<void> appendSamples(String runId, List<RunSample> batch) async {
    if (batch.isEmpty) return;
    await _db.batch((b) {
      b.insertAll(
        _db.runSamples,
        batch
            .map(
              (s) => RunSamplesCompanion.insert(
                runId: runId,
                tOffsetMs: s.tOffsetMs,
                lat: s.lat,
                lon: s.lon,
                elevationM: Value(s.elevation),
                instantSpeedMps: Value(s.instantSpeed),
              ),
            )
            .toList(),
      );
    });
  }

  Future<void> updateRunProgress({
    required String runId,
    required double distanceM,
    required int elapsedTimeSec,
    required int movingTimeSec,
  }) async {
    await (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
      RunsCompanion(
        distanceM: Value(distanceM),
        elapsedTimeSec: Value(elapsedTimeSec),
        movingTimeSec: Value(movingTimeSec),
      ),
    );
  }

  Future<void> finalizeRun({
    required String runId,
    required DateTime endedAt,
    required double distanceM,
    required int movingTimeSec,
    required int elapsedTimeSec,
    required double elevationGainM,
    required String? encodedPolyline,
  }) async {
    final avgPace = distanceM > 100
        ? movingTimeSec.toDouble() / (distanceM / 1000.0)
        : null;
    await (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
      RunsCompanion(
        endedAt: Value(endedAt),
        distanceM: Value(distanceM),
        movingTimeSec: Value(movingTimeSec),
        elapsedTimeSec: Value(elapsedTimeSec),
        elevationGainM: Value(elevationGainM),
        encodedPolyline: Value(encodedPolyline),
        avgPaceSecPerKm: Value(avgPace),
      ),
    );
  }

  Future<void> linkToSession(String runId, String sessionId) async {
    await (_db.update(_db.runs)..where((r) => r.id.equals(runId))).write(
      RunsCompanion(matchedSessionId: Value(sessionId)),
    );
  }

  Future<CompletedRun?> get(String runId) async {
    final row = await (_db.select(_db.runs)..where((r) => r.id.equals(runId)))
        .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  Stream<List<CompletedRun>> watchAll() {
    return (_db.select(_db.runs)
          ..orderBy([(r) => OrderingTerm.desc(r.startedAt)]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  Future<List<RunSample>> samplesFor(String runId) async {
    final rows = await (_db.select(_db.runSamples)
          ..where((s) => s.runId.equals(runId))
          ..orderBy([(s) => OrderingTerm.asc(s.tOffsetMs)]))
        .get();
    return rows
        .map(
          (r) => RunSample(
            lat: r.lat,
            lon: r.lon,
            elevation: r.elevationM,
            tOffsetMs: r.tOffsetMs,
            instantSpeed: r.instantSpeedMps ?? 0,
          ),
        )
        .toList();
  }

  /// Resume support: any run with no end time on app start is presumed crashed.
  Future<List<CompletedRun>> findOrphanedRuns() async {
    final rows = await (_db.select(_db.runs)
          ..where((r) => r.endedAt.isNull()))
        .get();
    return rows.map(_toDomain).toList();
  }

  CompletedRun _toDomain(RunRow row) => CompletedRun(
        id: row.id,
        startedAt: row.startedAt,
        endedAt: row.endedAt,
        distanceM: row.distanceM,
        movingTimeSec: row.movingTimeSec,
        elapsedTimeSec: row.elapsedTimeSec,
        avgPaceSecPerKm: row.avgPaceSecPerKm,
        elevationGainM: row.elevationGainM,
        encodedPolyline: row.encodedPolyline,
        source: row.source,
        matchedSessionId: row.matchedSessionId,
      );
}
