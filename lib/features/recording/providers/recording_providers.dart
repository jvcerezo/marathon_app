import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../service/recording_service.dart';

final recordingStateProvider = StreamProvider<RecordingState>(
  (ref) => ref.watch(recordingServiceProvider).state$,
);

/// Periodic ticker for live UI updates while recording (distance, duration).
final recordingTickProvider = StreamProvider<int>((ref) async* {
  int i = 0;
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield i++;
  }
});
