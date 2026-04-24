import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = false;
  bool _soundEnabled = false;
  bool _countdownSoundEnabled = true;
  bool _startSoundEnabled = true;
  bool _skipSoundEnabled = true;
  bool _prepEnabled = true;
  int _prepDuration = 10;
  bool _useDynamicColor = false;
  bool _isLoaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get countdownSoundEnabled => _countdownSoundEnabled;
  bool get startSoundEnabled => _startSoundEnabled;
  bool get skipSoundEnabled => _skipSoundEnabled;
  bool get prepEnabled => _prepEnabled;
  int get prepDuration => _prepDuration;
  bool get useDynamicColor => _useDynamicColor;
  bool get isLoaded => _isLoaded;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _useDynamicColor = prefs.getBool('useDynamicColor') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? false;
    _soundEnabled = prefs.getBool('soundEnabled') ?? false;
    _countdownSoundEnabled = prefs.getBool('countdownSoundEnabled') ?? true;
    _startSoundEnabled = prefs.getBool('startSoundEnabled') ?? true;
    _skipSoundEnabled = prefs.getBool('skipSoundEnabled') ?? true;
    _prepEnabled = prefs.getBool('prepEnabled') ?? true;
    _prepDuration = prefs.getInt('prepDuration') ?? 10;
    _isLoaded = true;

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }

  Future<void> setCountdownSoundEnabled(bool enabled) async {
    _countdownSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('countdownSoundEnabled', enabled);
  }

  Future<void> setStartSoundEnabled(bool enabled) async {
    _startSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startSoundEnabled', enabled);
  }

  Future<void> setSkipSoundEnabled(bool enabled) async {
    _skipSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('skipSoundEnabled', enabled);
  }

  Future<void> setPrepEnabled(bool enabled) async {
    _prepEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prepEnabled', enabled);
  }

  Future<void> setPrepDuration(int duration) async {
    _prepDuration = duration;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prepDuration', duration);
  }

  Future<void> setUseDynamicColor(bool enabled) async {
    _useDynamicColor = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useDynamicColor', enabled);
  }
}
