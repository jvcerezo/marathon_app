import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/math/geo_math.dart';
import '../../../core/math/polyline.dart';
import '../../../core/math/splits.dart';
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
    Map<int, double?> bestSplits = const <int, double?>{},
  }) async {
    final avgPace = (distanceM >= 10 && movingTimeSec > 0)
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
        bestSplit1kSec: Value(bestSplits[1000]),
        bestSplit5kSec: Value(bestSplits[5000]),
        bestSplit10kSec: Value(bestSplits[10000]),
        bestSplitHalfSec: Value(bestSplits[21098]),
        bestSplitMarathonSec: Value(bestSplits[42195]),
      ),
    );
  }

  /// Personal records across every completed run: the fastest split for
  /// each milestone distance. Returns a map keyed by distance (m) with
  /// the value `(timeSec, runId)` so callers can both display the time
  /// and link back to the run that set it. Distances with no qualifying
  /// run are absent from the result.
  Future<Map<int, ({double timeSec, String runId})>> personalRecords() async {
    final rows = await _db.select(_db.runs).get();
    final out = <int, ({double timeSec, String runId})>{};
    void track(int distanceM, double? Function(RunRow r) extract) {
      ({double timeSec, String runId})? best;
      for (final r in rows) {
        final t = extract(r);
        if (t == null || t <= 0) continue;
        if (best == null || t < best.timeSec) {
          best = (timeSec: t, runId: r.id);
        }
      }
      if (best != null) out[distanceM] = best;
    }

    track(1000, (r) => r.bestSplit1kSec);
    track(5000, (r) => r.bestSplit5kSec);
    track(10000, (r) => r.bestSplit10kSec);
    track(21098, (r) => r.bestSplitHalfSec);
    track(42195, (r) => r.bestSplitMarathonSec);
    return out;
  }

  /// For one specific milestone distance, returns the top-3 run ids
  /// ordered by best split (gold, silver, bronze). Used by the run
  /// detail "Achievements" section to figure out whether the current
  /// run earned a medal at this distance.
  Future<List<({double timeSec, String runId})>> topThreeFor(
      int targetDistanceM) async {
    final rows = await _db.select(_db.runs).get();
    final entries = <({double timeSec, String runId})>[];
    for (final r in rows) {
      final t = switch (targetDistanceM) {
        1000 => r.bestSplit1kSec,
        5000 => r.bestSplit5kSec,
        10000 => r.bestSplit10kSec,
        21098 => r.bestSplitHalfSec,
        42195 => r.bestSplitMarathonSec,
        _ => null,
      };
      if (t == null || t <= 0) continue;
      entries.add((timeSec: t, runId: r.id));
    }
    entries.sort((a, b) => a.timeSec.compareTo(b.timeSec));
    return entries.take(3).toList();
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

  /// Salvages runs whose recording session was killed before stop() ran.
  /// Reads back whatever samples did make it to disk via the periodic
  /// flush, recomputes distance / polyline / elevation / splits from
  /// those samples, and writes them onto the run row so the user still
  /// gets a complete summary instead of an empty stub.
  ///
  /// Returns the count of runs recovered. Runs that have zero samples
  /// (recording killed before the first flush) are deleted instead —
  /// they're useless and would otherwise clutter the run list forever.
  Future<int> recoverOrphans() async {
    final orphans = await findOrphanedRuns();
    if (orphans.isEmpty) return 0;
    int recovered = 0;
    for (final run in orphans) {
      final samples = await samplesFor(run.id);
      if (samples.length < 2) {
        // Nothing salvageable — drop the empty stub.
        await (_db.delete(_db.runSamples)
              ..where((s) => s.runId.equals(run.id)))
            .go();
        await (_db.delete(_db.runs)..where((r) => r.id.equals(run.id))).go();
        continue;
      }
      // Reconstruct distance from the persisted samples.
      double distanceM = 0;
      for (int i = 1; i < samples.length; i++) {
        distanceM += haversineMeters(
          samples[i - 1].lat,
          samples[i - 1].lon,
          samples[i].lat,
          samples[i].lon,
        );
      }
      final lastTOffsetMs = samples.last.tOffsetMs;
      final movingSec = (lastTOffsetMs / 1000).round();
      final endedAt =
          run.startedAt.add(Duration(milliseconds: lastTOffsetMs));

      final encoded = encodePolyline(
        simplify(
          samples.map((s) => (lat: s.lat, lon: s.lon)).toList(),
          4.0,
        ),
      );

      final splits = bestSplits(
        samples
            .map((s) =>
                (lat: s.lat, lon: s.lon, tOffsetMs: s.tOffsetMs))
            .toList(),
      );

      double elevGain = 0;
      const noiseFloorM = 2.0;
      double? anchor;
      for (final s in samples) {
        final el = s.elevation;
        if (el == null) continue;
        if (anchor == null) {
          anchor = el;
          continue;
        }
        final delta = el - anchor;
        if (delta >= noiseFloorM) {
          elevGain += delta;
          anchor = el;
        } else if (delta <= -noiseFloorM) {
          anchor = el;
        }
      }

      await finalizeRun(
        runId: run.id,
        endedAt: endedAt,
        distanceM: distanceM,
        movingTimeSec: movingSec,
        elapsedTimeSec: movingSec,
        elevationGainM: elevGain,
        encodedPolyline: encoded,
        bestSplits: splits,
      );
      recovered += 1;
    }
    return recovered;
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
        bestSplit1kSec: row.bestSplit1kSec,
        bestSplit5kSec: row.bestSplit5kSec,
        bestSplit10kSec: row.bestSplit10kSec,
        bestSplitHalfSec: row.bestSplitHalfSec,
        bestSplitMarathonSec: row.bestSplitMarathonSec,
      );
}
