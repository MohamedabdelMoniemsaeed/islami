import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  final String _lang = "ar";
  ThemeMode _mode = ThemeMode.light;

  String get lang => _lang;
  ThemeMode get mode => _mode;

  void changeTheme(ThemeMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }

  bool isDarkMode() => _mode == ThemeMode.dark;
}
