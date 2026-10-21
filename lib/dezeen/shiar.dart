import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  void setThemeMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }
}
