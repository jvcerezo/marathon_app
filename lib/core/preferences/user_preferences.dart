import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  final bool showMapDuringRecording;

  const UserPreferences({
    required this.showMapDuringRecording,
  });

  UserPreferences copyWith({
    bool? showMapDuringRecording,
  }) {
    return UserPreferences(
      showMapDuringRecording:
          showMapDuringRecording ?? this.showMapDuringRecording,
    );
  }

  static const defaults = UserPreferences(
    showMapDuringRecording: true,
  );
}

class _Keys {
  static const showMap = 'pref.showMapDuringRecording';
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
    );
  }

  Future<void> setShowMap(bool value) async {
    final p = _prefs ?? await SharedPreferences.getInstance();
    _prefs = p;
    await p.setBool(_Keys.showMap, value);
    state = state.copyWith(showMapDuringRecording: value);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
  (ref) => UserPreferencesNotifier(),
);
