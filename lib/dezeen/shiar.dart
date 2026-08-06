import 'package:flutter/material.dart';

import 'package:islami/services/api_service.dart';

class AppProvider extends ChangeNotifier {
  final String _lang = "ar";
  ThemeMode _mode = ThemeMode.light;
  List<dynamic> _surahs = [];
  int _currentQuranPage = 0;

  String get lang => _lang;
  ThemeMode get mode => _mode;
  List<dynamic> get surahs => _surahs;
  int get currentQuranPage => _currentQuranPage;

  void changeTheme(ThemeMode newMode) {
    if (_mode == newMode) return;
    _mode = newMode;
    notifyListeners();
  }

  bool isDarkMode() => _mode == ThemeMode.dark;

  void updateQuranPage(int page) {
    _currentQuranPage = page;
    notifyListeners();
  }

  Future<void> loadSurahs() async {
    if (_surahs.isNotEmpty) return;
    try {
      final dynamic data = await ApiService().getSurahsList();
      if (data is List) {
        _surahs = data;
      } else if (data is Map) {
        if (data.containsKey('value')) {
          _surahs = data['value'];
        } else if (data.containsKey('surahs')) {
          _surahs = data['surahs'];
        } else if (data.containsKey('data')) {
          _surahs = data['data'];
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading surahs in provider: $e");
    }
  }
}
