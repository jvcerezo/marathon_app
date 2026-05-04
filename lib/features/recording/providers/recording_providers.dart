import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../service/recording_service.dart';

final recordingStateProvider = StreamProvider<RecordingState>(
  (ref) => ref.watch(recordingServiceProvider).state$,
);

/// Watchdog stream — true when no GPS sample has arrived for 30+ seconds
/// during an active recording. The recording screen subscribes to this
/// to surface a "GPS signal lost" warning banner.
final gpsStaleProvider = StreamProvider<bool>(
  (ref) => ref.watch(recordingServiceProvider).gpsStale$,
);

/// Periodic ticker for live UI updates while recording (distance, duration).
final recordingTickProvider = StreamProvider<int>((ref) async* {
  int i = 0;
  while (true) {
    await Future<void>.delayed(const Duration(seconds: 1));
    yield i++;
  }
});
