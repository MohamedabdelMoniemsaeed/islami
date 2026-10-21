import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String keyPrayerTimes = 'cached_prayer_times';
  static const String keySurahsList = 'cached_surahs_list';
  static const String keyAzkar = 'cached_azkar';
  static const String keyDuas = 'cached_duas';

  Future<void> saveData(String key, String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  Future<String?> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  Future<void> saveSurah(int surahNumber, String data) async {
    await saveData('surah_$surahNumber', data);
  }

  Future<String?> getSurah(int surahNumber) async {
    return await getData('surah_$surahNumber');
  }

  Future<void> saveTafsir(int surahNumber, String data) async {
    await saveData('tafsir_$surahNumber', data);
  }

  Future<String?> getTafsir(int surahNumber) async {
    return await getData('tafsir_$surahNumber');
  }
}
