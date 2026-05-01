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
