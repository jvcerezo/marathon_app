import 'dart:async';

import '../../../core/math/geo_math.dart';
import '../models/raw_sample.dart';
import '../models/run_sample.dart';
import 'location_smoother.dart';
import 'outlier_filter.dart';

class RunRecorder {
  final OutlierFilter _filter = OutlierFilter();
  final LocationSmoother _smoother = LocationSmoother();
  final StreamController<RunSample> _samples = StreamController.broadcast();

  DateTime? _startedAt;
  DateTime? _autoPauseSinceTimestamp;
  RunSample? _lastSample;
  double _distanceM = 0.0;
  bool _autoPaused = false;
  bool _manuallyPaused = false;

  /// Total milliseconds spent in any paused state, summed over all
  /// previous pauses. Used so [elapsed] doesn't tick forward while
  /// paused.
  int _accumulatedPausedMs = 0;

  /// Wall-clock time the *current* pause started. Null when not paused.
  int? _currentPauseStartMs;

  static const double _autoPauseSpeedMps = 0.5;
  static const Duration _autoPauseAfter = Duration(seconds: 10);

  Stream<RunSample> get samples => _samples.stream;
  double get distanceM => _distanceM;
  bool get isPaused => _autoPaused || _manuallyPaused;

  /// Wall-clock time since the run began, with paused intervals subtracted.
  Duration get elapsed {
    final start = _startedAt;
    if (start == null) return Duration.zero;
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final raw = nowMs - start.millisecondsSinceEpoch;
    final pausedNow = _currentPauseStartMs == null
        ? 0
        : nowMs - _currentPauseStartMs!;
    final totalPaused = _accumulatedPausedMs + pausedNow;
    final adjusted = raw - totalPaused;
    return Duration(milliseconds: adjusted < 0 ? 0 : adjusted);
  }

  void start() {
    _startedAt = DateTime.now();
    _accumulatedPausedMs = 0;
    _currentPauseStartMs = null;
  }

  void pause() {
    if (_manuallyPaused) return;
    _manuallyPaused = true;
    _currentPauseStartMs ??= DateTime.now().millisecondsSinceEpoch;
  }

  void resume() {
    if (!_manuallyPaused) return;
    _manuallyPaused = false;
    // Only stop the pause clock if auto-pause isn't holding us paused too.
    if (!_autoPaused && _currentPauseStartMs != null) {
      _accumulatedPausedMs +=
          DateTime.now().millisecondsSinceEpoch - _currentPauseStartMs!;
      _currentPauseStartMs = null;
    }
  }

  void onRawSample(RawSample raw) {
    if (_startedAt == null) return;

    // While paused, do not advance distance, do not append to the
    // polyline, and do not emit. The map and stats freeze.
    if (isPaused) {
      _updateAutoPause(raw.speed);
      // If auto-pause clears (user moved again) and we're not manually
      // paused, exit the pause cleanly so elapsed resumes ticking.
      if (!isPaused && _currentPauseStartMs != null) {
        _accumulatedPausedMs +=
            DateTime.now().millisecondsSinceEpoch - _currentPauseStartMs!;
        _currentPauseStartMs = null;
      }
      return;
    }

    final accepted = _filter.accept(raw);
    if (accepted == null) return;

    final smoothed = _smoother.smooth(accepted);
    final wasAutoPaused = _autoPaused;
    _updateAutoPause(raw.speed);
    if (_autoPaused && !wasAutoPaused) {
      // Just entered auto-pause; mark the pause-start clock.
      _currentPauseStartMs ??= DateTime.now().millisecondsSinceEpoch;
      return;
    }

    final sample = RunSample(
      lat: smoothed.lat,
      lon: smoothed.lon,
      elevation: raw.elevation,
      tOffsetMs: elapsed.inMilliseconds,
      instantSpeed: raw.speed,
    );

    final last = _lastSample;
    if (last != null) {
      _distanceM += haversineMeters(last.lat, last.lon, sample.lat, sample.lon);
    }

    _lastSample = sample;
    _samples.add(sample);
  }

  void _updateAutoPause(double speedMps) {
    final now = DateTime.now();
    if (speedMps < _autoPauseSpeedMps) {
      _autoPauseSinceTimestamp ??= now;
      if (now.difference(_autoPauseSinceTimestamp!) >= _autoPauseAfter) {
        _autoPaused = true;
      }
    } else {
      _autoPauseSinceTimestamp = null;
      _autoPaused = false;
    }
  }

  Future<void> dispose() => _samples.close();
}
