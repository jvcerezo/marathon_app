import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';

import '../models/run_sample.dart';
import '../pipeline/run_recorder.dart';

/// Speaks distance + pace at every kilometer mark while recording, so users
/// can lock their phone and run without losing feedback. Uses the platform
/// TTS engine — no network needed once the engine is initialized.
class AudioCueService {
  final FlutterTts _tts = FlutterTts();
  StreamSubscription<RunSample>? _sub;
  RunRecorder? _recorder;
  int _lastKmAnnounced = 0;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);
    _initialized = true;
  }

  Future<void> start(RunRecorder recorder) async {
    await _ensureInitialized();
    _recorder = recorder;
    _lastKmAnnounced = 0;
    await _sub?.cancel();
    _sub = recorder.samples.listen(_onSample);
  }

  void _onSample(RunSample _) {
    final r = _recorder;
    if (r == null) return;
    final km = (r.distanceM / 1000).floor();
    if (km > _lastKmAnnounced && km > 0) {
      _lastKmAnnounced = km;
      _announce(km, r);
    }
  }

  Future<void> _announce(int km, RunRecorder r) async {
    if (r.distanceM <= 0) return;
    final paceSecPerKm = (r.elapsed.inSeconds / (r.distanceM / 1000)).round();
    final paceMin = paceSecPerKm ~/ 60;
    final paceSec = paceSecPerKm % 60;

    final kmWord = km == 1 ? 'kilometer' : 'kilometers';
    final paceWord = paceSec == 0
        ? '$paceMin minutes per kilometer'
        : '$paceMin ${paceMin == 1 ? 'minute' : 'minutes'} '
            '$paceSec ${paceSec == 1 ? 'second' : 'seconds'} per kilometer';

    await _tts.speak('$km $kmWord. Pace, $paceWord.');
  }

  Future<void> announceFinish(double distanceM, Duration elapsed) async {
    if (!_initialized) return;
    if (distanceM <= 0) return;
    final paceSecPerKm = (elapsed.inSeconds / (distanceM / 1000)).round();
    final paceMin = paceSecPerKm ~/ 60;
    final paceSec = paceSecPerKm % 60;
    final km = (distanceM / 1000).toStringAsFixed(2);
    await _tts.speak(
      'Run complete. $km kilometers in ${elapsed.inMinutes} minutes. '
      'Average pace, $paceMin minutes $paceSec seconds per kilometer.',
    );
  }

  Future<void> stop() async {
    await _sub?.cancel();
    _sub = null;
    _recorder = null;
    await _tts.stop();
  }
}
