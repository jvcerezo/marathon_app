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

enum RecordingState { idle, awaitingFix, recording, paused, stopped }

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

  final List<RunSample> _buffer = [];
  final List<RunSample> _allSamples = [];

  final _stateController = StreamController<RecordingState>.broadcast();
  RecordingState _state = RecordingState.idle;

  Stream<RecordingState> get state$ => _stateController.stream;
  RecordingState get state => _state;

  RunRecorder? get recorder => _recorder;
  String? get currentRunId => _runId;
  List<RunSample> get currentSamples => List.unmodifiable(_allSamples);

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
    final startedAt = DateTime.now();
    await _runs.createRun(id: _runId!, startedAt: startedAt);

    _recorder = RunRecorder()..start();
    if (keepScreenAwake) {
      await WakelockPlus.enable();
      _wakelockEnabled = true;
    }
    if (audioCues) {
      await _audio.start(_recorder!);
    }

    _setState(RecordingState.awaitingFix);

    _gpsSub = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 1),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Recording run',
          notificationText: 'Tap to return',
          // The geolocator wake lock keeps the GPS chip awake. The screen
          // can still sleep. WiFi lock helps with assisted positioning.
          enableWakeLock: true,
          enableWifiLock: true,
        ),
      ),
    ).listen((p) {
      if (_state == RecordingState.awaitingFix && p.accuracy <= 30) {
        _setState(RecordingState.recording);
      }
      _recorder!.onRawSample(
        RawSample(
          lat: p.latitude,
          lon: p.longitude,
          elevation: p.altitude,
          accuracy: p.accuracy,
          speed: p.speed,
          timestamp: p.timestamp,
        ),
      );
    });

    _sampleSub = _recorder!.samples.listen((s) {
      _buffer.add(s);
      _allSamples.add(s);
    });

    _flushTimer =
        Timer.periodic(const Duration(seconds: 10), (_) => _flush());
  }

  void pause() {
    _recorder?.pause();
    _setState(RecordingState.paused);
  }

  void resume() {
    _recorder?.resume();
    _setState(RecordingState.recording);
  }

  Future<CompletedRun> stop() async {
    final runId = _runId;
    final recorder = _recorder;
    if (runId == null || recorder == null) {
      throw StateError('No active recording.');
    }
    await _flush();
    await _gpsSub?.cancel();
    await _sampleSub?.cancel();
    _flushTimer?.cancel();

    final endedAt = DateTime.now();
    final elapsedSec = recorder.elapsed.inSeconds;
    final movingSec = elapsedSec; // TODO: track paused time precisely

    final encoded = encodePolyline(
      simplify(
        _allSamples.map((s) => (lat: s.lat, lon: s.lon)).toList(),
        4.0, // 4-meter tolerance
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
    // Speak the summary before tearing the TTS engine down.
    await _audio.announceFinish(recorder.distanceM, recorder.elapsed);
    await _audio.stop();
    await recorder.dispose();

    final run = await _runs.get(runId);
    _reset();
    return run!;
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
    _buffer.clear();
    _allSamples.clear();
    _setState(RecordingState.idle);
  }
}
