import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final bool showMapDuringRecording;
  final bool audioCuesEnabled;
  final bool keepScreenAwake;

  const UserPreferences({
    required this.showMapDuringRecording,
    required this.audioCuesEnabled,
    required this.keepScreenAwake,
  });

  UserPreferences copyWith({
    bool? showMapDuringRecording,
    bool? audioCuesEnabled,
    bool? keepScreenAwake,
  }) {
    return UserPreferences(
      showMapDuringRecording:
          showMapDuringRecording ?? this.showMapDuringRecording,
      audioCuesEnabled: audioCuesEnabled ?? this.audioCuesEnabled,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
    );
  }

  /// Audio cues default to OFF — the platform TTS voice on most Android
  /// devices is jarring enough that a per-km announcement is more
  /// annoying than helpful. Users who want it can opt in from Settings.
  static const defaults = UserPreferences(
    showMapDuringRecording: true,
    audioCuesEnabled: false,
    keepScreenAwake: false,
  );
}

class _Keys {
  static const showMap = 'pref.showMapDuringRecording';
  static const audio = 'pref.audioCuesEnabled';
  static const screen = 'pref.keepScreenAwake';
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  UserPreferencesNotifier() : super(UserPreferences.defaults) {
    _load();
  }

  SharedPreferences? _prefs;

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    state = UserPreferences(
      showMapDuringRecording: _prefs!.getBool(_Keys.showMap) ?? true,
      audioCuesEnabled: _prefs!.getBool(_Keys.audio) ?? false,
      keepScreenAwake: _prefs!.getBool(_Keys.screen) ?? false,
    );
  }

  Future<SharedPreferences> _ensure() async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    return p;
  }

  Future<void> setShowMap(bool value) async {
    final p = await _ensure();
    await p.setBool(_Keys.showMap, value);
    state = state.copyWith(showMapDuringRecording: value);
  }

  Future<void> setAudioCues(bool value) async {
    final p = await _ensure();
    await p.setBool(_Keys.audio, value);
    state = state.copyWith(audioCuesEnabled: value);
  }

  Future<void> setKeepScreenAwake(bool value) async {
    final p = await _ensure();
    await p.setBool(_Keys.screen, value);
    state = state.copyWith(keepScreenAwake: value);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  (ref) => UserPreferencesNotifier(),
);
