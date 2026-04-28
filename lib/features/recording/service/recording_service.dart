import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/math/polyline.dart';
import '../../runs/models/completed_run.dart';
import '../../runs/repository/runs_repository.dart';
import '../models/raw_sample.dart';
import '../models/run_sample.dart';
import '../pipeline/run_recorder.dart';
import 'audio_cue_service.dart';

enum RecordingState {
  /// Nothing happening.
  idle,

  /// GPS stream open, waiting for the first usable fix.
  awaitingFix,

  /// First fix arrived. The map can show the user's location, but the
  /// recorder hasn't started yet — waiting for the user to tap Start.
  ready,

  /// Recorder is actively accumulating distance and time.
  recording,

  /// Recording was started and the user has paused it.
  paused,

  /// Run was finalized.
  stopped,
}

class RecordingService {
  final RunsRepository _runs;
  final Uuid _uuid;
  final AudioCueService _audio = AudioCueService();

  RecordingService(this._runs, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  RunRecorder? _recorder;
  StreamSubscription<Position>? _gpsSub;
  StreamSubscription<RunSample>? _sampleSub;
  Timer? _flushTimer;
  String? _runId;
  bool _wakelockEnabled = false;
  bool _audioEnabled = false;

  /// True after the user has pressed Start Run. Until then we're holding
  /// in the ready state, displaying the location dot but not recording.
  bool _runStarted = false;

  /// Latest GPS fix observed during the awaitingFix/ready window. Used so
  /// the map can show a marker at the user's location before recording.
  RunSample? _previewSample;

  final List<RunSample> _buffer = [];
  final List<RunSample> _allSamples = [];

  final _stateController = StreamController<RecordingState>.broadcast();
  RecordingState _state = RecordingState.idle;

  Stream<RecordingState> get state$ => _stateController.stream;
  RecordingState get state => _state;

  RunRecorder? get recorder => _recorder;
  String? get currentRunId => _runId;

  /// Samples used by the map. While recording: the full route. While
  /// preparing: a single point at the current location so the marker
  /// can render.
  List<RunSample> get currentSamples {
    if (_runStarted) return List.unmodifiable(_allSamples);
    final p = _previewSample;
    if (p != null) return [p];
    return const [];
  }

  Future<bool> ensurePermissions() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) return false;
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled &&
        (permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse);
  }

  /// Opens the GPS stream and prepares the recorder, but does NOT start
  /// it. Once a usable fix arrives the state moves to `ready` and the UI
  /// can render a Start Run button. Recording only begins when the user
  /// taps it (see [begin]).
  Future<void> start({
    bool keepScreenAwake = false,
    bool audioCues = true,
  }) async {
    if (_state != RecordingState.idle) return;
    final ok = await ensurePermissions();
    if (!ok) {
      throw StateError('Location permission denied or services off.');
    }

    _runId = _uuid.v4();
    _audioEnabled = audioCues;
    _runStarted = false;
    _previewSample = null;
    _allSamples.clear();
    _buffer.clear();

    _recorder = RunRecorder(); // not started

    if (keepScreenAwake) {
      await WakelockPlus.enable();
      _wakelockEnabled = true;
    }

    _setState(RecordingState.awaitingFix);

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 3,
        intervalDuration: const Duration(seconds: 2),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Marathon',
          notificationText: 'GPS active',
          enableWakeLock: true,
          enableWifiLock: true,
        ),
      ),
    ).listen(_onPosition);
  }

  void _onPosition(Position p) {
    // Promote awaitingFix -> ready as soon as we have a usable fix.
    if (_state == RecordingState.awaitingFix && p.accuracy <= 30) {
      _setState(RecordingState.ready);
    }

    final raw = RawSample(
      lat: p.latitude,
      lon: p.longitude,
      elevation: p.altitude,
      accuracy: p.accuracy,
      speed: p.speed,
      timestamp: p.timestamp,
    );

    if (_runStarted && _recorder != null) {
      _recorder!.onRawSample(raw);
    } else if (_state == RecordingState.ready) {
      // Update preview marker for the live map.
      _previewSample = RunSample(
        lat: p.latitude,
        lon: p.longitude,
        elevation: p.altitude,
        tOffsetMs: 0,
        instantSpeed: p.speed,
      );
    }
  }

  /// User has tapped Start Run. Now actually start the recorder and the
  /// flush/audio plumbing. Idempotent if already recording.
  Future<void> begin() async {
    if (_state == RecordingState.recording) return;
    if (_state != RecordingState.ready) {
      throw StateError('Cannot begin: still acquiring GPS.');
    }
    final recorder = _recorder!;
    final runId = _runId!;

    _runStarted = true;
    recorder.start();

    await _runs.createRun(id: runId, startedAt: DateTime.now());

    if (_audioEnabled) {
      await _audio.start(recorder);
    }

    _sampleSub = recorder.samples.listen((s) {
      _buffer.add(s);
      _allSamples.add(s);
    });

    _flushTimer = Timer.periodic(const Duration(seconds: 30), (_) => _flush());

    _setState(RecordingState.recording);
  }

  void pause() {
    _recorder?.pause();
    _setState(RecordingState.paused);
  }

  void resume() {
    _recorder?.resume();
    _setState(RecordingState.recording);
  }

  /// Tear down a prepared-but-not-yet-started recording (user backed out
  /// before pressing Start).
  Future<void> cancelPrep() async {
    await _gpsSub?.cancel();
    if (_wakelockEnabled) {
      await WakelockPlus.disable();
      _wakelockEnabled = false;
    }
    _reset();
  }

  Future<CompletedRun?> stop() async {
    final runId = _runId;
    final recorder = _recorder;
    if (runId == null || recorder == null) return null;

    if (!_runStarted) {
      // Never actually started. Treat as cancel.
      await cancelPrep();
      return null;
    }

    await _flush();
    await _gpsSub?.cancel();
    await _sampleSub?.cancel();
    _flushTimer?.cancel();

    final endedAt = DateTime.now();
    final elapsedSec = recorder.elapsed.inSeconds;
    final movingSec = elapsedSec; // already excludes paused intervals

    final encoded = encodePolyline(
      simplify(
        _allSamples.map((s) => (lat: s.lat, lon: s.lon)).toList(),
        4.0,
      ),
    );

    await _runs.finalizeRun(
      runId: runId,
      endedAt: endedAt,
      distanceM: recorder.distanceM,
      movingTimeSec: movingSec,
      elapsedTimeSec: elapsedSec,
      elevationGainM: 0,
      encodedPolyline: encoded,
    );

    if (_wakelockEnabled) {
      await WakelockPlus.disable();
      _wakelockEnabled = false;
    }
    await _audio.announceFinish(recorder.distanceM, recorder.elapsed);
    await _audio.stop();
    await recorder.dispose();

    final run = await _runs.get(runId);
    _reset();
    return run;
  }

  Future<void> _flush() async {
    final runId = _runId;
    final recorder = _recorder;
    if (runId == null || recorder == null) return;
    if (_buffer.isEmpty) return;
    final batch = List<RunSample>.from(_buffer);
    _buffer.clear();
    await _runs.appendSamples(runId, batch);
    await _runs.updateRunProgress(
      runId: runId,
      distanceM: recorder.distanceM,
      elapsedTimeSec: recorder.elapsed.inSeconds,
      movingTimeSec: recorder.elapsed.inSeconds,
    );
  }

  void _setState(RecordingState s) {
    _state = s;
    _stateController.add(s);
  }

  void _reset() {
    _runId = null;
    _recorder = null;
    _gpsSub = null;
    _sampleSub = null;
    _flushTimer = null;
    _runStarted = false;
    _previewSample = null;
    _buffer.clear();
    _allSamples.clear();
    _setState(RecordingState.idle);
  }
}
