import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../models/completed_run.dart';

final runsProvider = StreamProvider<List<CompletedRun>>(
  (ref) => ref.watch(runsRepositoryProvider).watchAll(),
);

final runDetailProvider =
    FutureProvider.family<CompletedRun?, String>((ref, runId) async {
  return ref.watch(runsRepositoryProvider).get(runId);
});
