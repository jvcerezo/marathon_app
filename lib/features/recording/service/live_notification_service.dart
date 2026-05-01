import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../pipeline/run_recorder.dart';

/// Strava-style ongoing notification that mirrors the recorder's live
/// stats. Updates on a 3-second cadence so the lockscreen and pull-down
/// shade always show the latest distance, elapsed time, and current
/// pace without the user unlocking the phone.
///
/// The geolocator package owns its own foreground-service notification
/// (separate, minimal). This service posts a parallel notification on
/// our own channel so we can fully control the title/body content.
class LiveNotificationService {
  static const String _channelId = 'daloy_run_live';
  static const String _channelName = 'Run progress';
  static const String _channelDescription =
      'Live distance, time, and pace while recording a run';
  static const int _notificationId = 4242;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  Timer? _ticker;
  RunRecorder? _recorder;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: androidInit);
    await _plugin.initialize(init);

    // Pre-create the channel so the system shows it in user-visible app
    // notification settings ("Run progress") even before the first post.
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(const AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.low, // no sound or heads-up; ongoing only
      playSound: false,
      enableVibration: false,
      showBadge: false,
    ));
    _initialized = true;
  }

  Future<void> start(RunRecorder recorder) async {
    await _ensureInitialized();
    _recorder = recorder;
    // First update immediately, then on a 3s cadence. Notification
    // updates more often than this don't render on most Android skins
    // and waste battery.
    await _post();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 3), (_) => _post());
  }

  Future<void> stop() async {
    _ticker?.cancel();
    _ticker = null;
    _recorder = null;
    await _plugin.cancel(_notificationId);
  }

  Future<void> _post() async {
    final r = _recorder;
    if (r == null) return;
    final paused = r.isPaused;
    final distKm = r.distanceM / 1000.0;
    final elapsed = r.elapsed;
    final paceSecPerKm =
        distKm > 0.01 ? (elapsed.inSeconds / distKm).round() : null;

    final distText = '${distKm.toStringAsFixed(2)} km';
    final timeText = _formatDuration(elapsed);
    final paceText = paceSecPerKm == null
        ? '--:--/km'
        : '${paceSecPerKm ~/ 60}:${(paceSecPerKm % 60).toString().padLeft(2, '0')}/km';

    final title = paused ? 'Daloy · Paused' : distText;
    final body = paused
        ? '$distText · $timeText'
        : '$timeText · $paceText';

    await _plugin.show(
      _notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: false,
          playSound: false,
          enableVibration: false,
          category: AndroidNotificationCategory.workout,
          visibility: NotificationVisibility.public,
        ),
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) {
      return '$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
