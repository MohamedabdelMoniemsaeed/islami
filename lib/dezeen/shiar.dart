import 'package:flutter/material.dart';

import 'package:islami/services/api_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  final String _lang = "ar";
  ThemeMode _mode = ThemeMode.light;
  List<dynamic> _surahs = [];
  int _currentQuranPage = 0;
  int? _bookmarkedPage;
  int _jumpRequests = 0; // عداد لطلبات الانتقال لضمان الاستجابة المتكررة

  String get lang => _lang;
  ThemeMode get mode => _mode;
  List<dynamic> get surahs => _surahs;
  int get currentQuranPage => _currentQuranPage;
  int? get bookmarkedPage => _bookmarkedPage;
  int get jumpRequests => _jumpRequests;

  AppProvider() {
    loadBookmark();
  }

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

  void requestJumpToPage(int page) {
    _currentQuranPage = page;
    _jumpRequests++; // زيادة العداد لإخبار الواجهة بوجود طلب جديد
    notifyListeners();
  }

  Future<void> saveBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('quran_bookmark', _currentQuranPage);
    _bookmarkedPage = _currentQuranPage;
    notifyListeners();
  }

  Future<void> loadBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    _bookmarkedPage = prefs.getInt('quran_bookmark');
    notifyListeners();
  }

  Future<void> clearBookmark() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('quran_bookmark');
    _bookmarkedPage = null;
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
