import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // مفاتيح التخزين
  static const String keyPrayerTimes = 'prayer_times_cache';
  static const String keyRadios = 'radios_cache';
  static const String keyAzkar = 'azkar_cache';
  static const String keyDuas = 'duas_cache';
  static const String keySurahsList = 'surahs_list_cache';
  static const String keySurahPrefix = 'surah_cache_';
  static const String keyTafsirPrefix = 'tafsir_cache_';

  Future<void> saveData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // وظائف خاصة للسور والتفاسير لأنها تعتمد على الرقم
  Future<void> saveSurah(int number, String data) => saveData('$keySurahPrefix$number', data);
  Future<String?> getSurah(int number) => getData('$keySurahPrefix$number');

  Future<void> saveTafsir(int number, String data) => saveData('$keyTafsirPrefix$number', data);
  Future<String?> getTafsir(int number) => getData('$keyTafsirPrefix$number');
}
