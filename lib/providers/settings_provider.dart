import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kTheme = 'theme';
  static const _kScale = 'textScale';

  ThemeMode _themeMode = ThemeMode.system;
  double _textScale = 1.0; // 0.8 - 1.4 proponowany zakres

  SettingsProvider() {
    _load();
  }

  ThemeMode get themeMode => _themeMode;
  double get textScale => _textScale;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_kTheme);
    if (themeIndex != null) _themeMode = ThemeMode.values[themeIndex];
    _textScale = prefs.getDouble(_kScale) ?? 1.0;
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode m) async {
    _themeMode = m;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTheme, m.index);
  }

  Future<void> setTextScale(double v) async {
    _textScale = v;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kScale, v);
  }
}
