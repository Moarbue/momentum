import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _countdownSoundEnabled = true;
  bool _startSoundEnabled = true;
  bool _prepEnabled = true;
  int _prepDuration = 10;
  bool _removeLastRestEnabled = false;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get soundEnabled => _soundEnabled;
  bool get countdownSoundEnabled => _countdownSoundEnabled;
  bool get startSoundEnabled => _startSoundEnabled;
  bool get prepEnabled => _prepEnabled;
  int get prepDuration => _prepDuration;
  bool get removeLastRestEnabled => _removeLastRestEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt('themeMode') ?? 0;
    _themeMode = ThemeMode.values[themeIndex];

    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _countdownSoundEnabled = prefs.getBool('countdownSoundEnabled') ?? true;
    _startSoundEnabled = prefs.getBool('startSoundEnabled') ?? true;
    _prepEnabled = prefs.getBool('prepEnabled') ?? true;
    _prepDuration = prefs.getInt('prepDuration') ?? 10;
    _removeLastRestEnabled = prefs.getBool('removeLastRestEnabled') ?? false;

    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  void setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', enabled);
  }

  void setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }

  void setCountdownSoundEnabled(bool enabled) async {
    _countdownSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('countdownSoundEnabled', enabled);
  }

  void setStartSoundEnabled(bool enabled) async {
    _startSoundEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('startSoundEnabled', enabled);
  }

  void setPrepEnabled(bool enabled) async {
    _prepEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prepEnabled', enabled);
  }

  void setPrepDuration(int duration) async {
    _prepDuration = duration;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('prepDuration', duration);
  }

  void setRemoveLastRestEnabled(bool enabled) async {
    _removeLastRestEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('removeLastRestEnabled', enabled);
  }
}
