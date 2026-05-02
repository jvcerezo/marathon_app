import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../recording/models/run_sample.dart';
import '../models/completed_run.dart';

final runsProvider = StreamProvider<List<CompletedRun>>(
  (ref) => ref.watch(runsRepositoryProvider).watchAll(),
);

final runDetailProvider =
    FutureProvider.family<CompletedRun?, String>((ref, runId) async {
  return ref.watch(runsRepositoryProvider).get(runId);
});

final runSamplesProvider =
    FutureProvider.family<List<RunSample>, String>((ref, runId) async {
  return ref.watch(runsRepositoryProvider).samplesFor(runId);
});

/// Per-distance personal records across the whole run history. Map key
/// is distance in meters (1000, 5000, 10000, 21098, 42195); value is
/// `(timeSec, runId)` for the run that holds the PR.
final personalRecordsProvider = FutureProvider<
    Map<int, ({double timeSec, String runId})>>((ref) async {
  return ref.watch(runsRepositoryProvider).personalRecords();
});

/// For a given run, returns the medal earned at each milestone distance
/// (gold/silver/bronze = 1/2/3). Distances where the run isn't in the
/// top 3 are absent.
final runMedalsProvider =
    FutureProvider.family<Map<int, int>, String>((ref, runId) async {
  final repo = ref.watch(runsRepositoryProvider);
  final out = <int, int>{};
  for (final d in const [1000, 5000, 10000, 21098, 42195]) {
    final top = await repo.topThreeFor(d);
    final idx = top.indexWhere((e) => e.runId == runId);
    if (idx >= 0) out[d] = idx + 1;
  }
  return out;
});
