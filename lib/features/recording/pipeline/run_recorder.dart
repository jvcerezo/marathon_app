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
  DateTime? _pauseStartedAt;
  RunSample? _lastSample;
  double _distanceM = 0.0;
  bool _autoPaused = false;
  bool _manuallyPaused = false;

  static const double _autoPauseSpeedMps = 0.5;
  static const Duration _autoPauseAfter = Duration(seconds: 10);

  Stream<RunSample> get samples => _samples.stream;
  double get distanceM => _distanceM;
  bool get isPaused => _autoPaused || _manuallyPaused;
  Duration get elapsed => _startedAt == null
      ? Duration.zero
      : DateTime.now().difference(_startedAt!);

  void start() {
    _startedAt = DateTime.now();
  }

  void pause() => _manuallyPaused = true;
  void resume() => _manuallyPaused = false;

  void onRawSample(RawSample raw) {
    if (_startedAt == null) return;
    final accepted = _filter.accept(raw);
    if (accepted == null) return;

    final smoothed = _smoother.smooth(accepted);
    _updateAutoPause(raw.speed);

    final sample = RunSample(
      lat: smoothed.lat,
      lon: smoothed.lon,
      elevation: raw.elevation,
      tOffsetMs: DateTime.now().difference(_startedAt!).inMilliseconds,
      instantSpeed: raw.speed,
    );

    final last = _lastSample;
    if (last != null && !isPaused) {
      _distanceM += haversineMeters(last.lat, last.lon, sample.lat, sample.lon);
    }

    _lastSample = sample;
    _samples.add(sample);
  }

  void _updateAutoPause(double speedMps) {
    final now = DateTime.now();
    if (speedMps < _autoPauseSpeedMps) {
      _pauseStartedAt ??= now;
      if (now.difference(_pauseStartedAt!) >= _autoPauseAfter) {
        _autoPaused = true;
      }
    } else {
      _pauseStartedAt = null;
      _autoPaused = false;
    }
  }

  Future<void> dispose() => _samples.close();
}
