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

  /// Speed below which a sample counts toward the auto-pause window.
  /// Slow walking sits ~1.0 m/s; we set this at 0.3 to avoid pausing on
  /// turnarounds, slow climbs, or brief direction reversals where the
  /// GPS chip momentarily reports near-zero speed.
  static const double _autoPauseSpeedMps = 0.3;

  /// How long the user must remain near-stationary before we auto-pause.
  /// Long enough to absorb the dwell at a stoplight or a U-turn without
  /// short enough to actually cut elapsed time when the user truly stops.
  static const Duration _autoPauseAfter = Duration(seconds: 15);

  /// Cross-check the speed-based pause: if the smoothed position has
  /// moved more than this many meters since [_autoPauseSinceTimestamp],
  /// the user is moving and we cancel the pending pause. This stops a
  /// noisy speed reading from triggering a pause during real motion.
  static const double _autoPauseMaxDriftM = 5.0;
  ({double lat, double lon})? _autoPauseAnchor;

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
      // We still need a smoothed position to feed the stationary check —
      // but we explicitly do NOT call _smoother.smooth() while paused so
      // its variance and timestamp don't drift.
      _updateAutoPause(raw.speed, smoothed: null);
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
    _updateAutoPause(raw.speed, smoothed: smoothed);
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

  void _updateAutoPause(
    double speedMps, {
    required ({double lat, double lon})? smoothed,
  }) {
    final now = DateTime.now();
    if (speedMps < _autoPauseSpeedMps) {
      // Establish or keep the pause-pending window.
      if (_autoPauseSinceTimestamp == null) {
        _autoPauseSinceTimestamp = now;
        _autoPauseAnchor = smoothed;
      }
      // Cross-check: if the smoothed position has drifted significantly
      // since the window opened, the speed reading was a transient blip
      // and we should not pause.
      final anchor = _autoPauseAnchor;
      if (smoothed != null && anchor != null) {
        final drift = haversineMeters(
          anchor.lat,
          anchor.lon,
          smoothed.lat,
          smoothed.lon,
        );
        if (drift > _autoPauseMaxDriftM) {
          _autoPauseSinceTimestamp = null;
          _autoPauseAnchor = null;
          _autoPaused = false;
          return;
        }
      }
      if (now.difference(_autoPauseSinceTimestamp!) >= _autoPauseAfter) {
        _autoPaused = true;
      }
    } else {
      _autoPauseSinceTimestamp = null;
      _autoPauseAnchor = null;
      _autoPaused = false;
    }
  }

  Future<void> dispose() => _samples.close();
}
