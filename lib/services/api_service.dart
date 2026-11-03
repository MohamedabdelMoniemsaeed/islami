import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/models/duas_model.dart';
import 'package:islami/services/cache_service.dart';

class ApiService {
  static const String _prayerBaseUrl = 'https://quran.yousefheiba.com/api/getPrayerTimes';
  static const String _quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _hadithBaseUrl = 'https://hadis-api-id.vercel.app/hadith';
  static const String _tafsirBaseUrl = 'https://quranenc.com/api/v1/translation/sura/arabic_moyassar';
  static const String _azkarUrl = 'https://quran.yousefheiba.com/api/azkar';
  static const String _duasUrl = 'https://quran.yousefheiba.com/api/duas';
  static const String _surahsListUrl = 'https://quran.yousefheiba.com/api/surahs';
  static const String _ayahsBySurahUrl = 'https://quran.yousefheiba.com/api/ayah?number=';
  static const String _laylatAlQadrUrl = 'https://quran.yousefheiba.com/api/laylatAlQadr';
  static const String _recitersUrl = 'https://quran.yousefheiba.com/api/reciterAudio?reciter_id=';

  final CacheService _cacheService = CacheService();

  Future<List<dynamic>> getAyahsBySurah(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$_ayahsBySurahUrl$surahNumber')).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        return json.decode(decodedBody);
      }
      throw Exception('Server Error');
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getLaylatAlQadr() async {
    try {
      final response = await http.get(Uri.parse(_laylatAlQadrUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      throw Exception('Failed to load data');
    } catch (e) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getReciterAudio(int reciterId) async {
    try {
      final response = await http.get(Uri.parse('$_recitersUrl$reciterId')).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes));
      }
      throw Exception('Server Error');
    } catch (e) {
      return {};
    }
  }

  Future<PrayerTimes> getPrayerTimes() async {
    try {
      final response = await http.get(Uri.parse(_prayerBaseUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyPrayerTimes, decodedBody);
        return PrayerTimes.fromJson(json.decode(decodedBody));
      }
      throw Exception('Failed to load from server');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyPrayerTimes);
      if (localData != null) {
        try {
          return PrayerTimes.fromJson(json.decode(localData));
        } catch (_) {
          await _cacheService.removeData(CacheService.keyPrayerTimes);
        }
      }
      throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة');
    }
  }

  Future<SurahApiResponse> getSurah(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$_quranBaseUrl/surah/$surahNumber')).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveSurah(surahNumber, decodedBody);
        return SurahApiResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getSurah(surahNumber);
      if (localData != null) {
        try {
          return SurahApiResponse.fromJson(json.decode(localData));
        } catch (_) {
          await _cacheService.removeData('${CacheService.keySurahPrefix}$surahNumber');
        }
      }
      throw Exception('هذه السورة غير محملة مسبقاً، يرجى الاتصال بالإنترنت');
    }
  }

  Future<DuasResponse> getDuas() async {
    try {
      final response = await http.get(Uri.parse(_duasUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyDuas, decodedBody);
        return DuasResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyDuas);
      if (localData != null) {
        try {
          return DuasResponse.fromJson(json.decode(localData));
        } catch (_) {
          await _cacheService.removeData(CacheService.keyDuas);
        }
      }
      throw Exception('الأدعية غير متوفرة حالياً بدون إنترنت');
    }
  }

  Future<TafsirResponse> getTafsir(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$_tafsirBaseUrl/$surahNumber')).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveTafsir(surahNumber, decodedBody);
        return TafsirResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getTafsir(surahNumber);
      if (localData != null) {
        try {
          return TafsirResponse.fromJson(json.decode(localData));
        } catch (_) {
          await _cacheService.removeData('${CacheService.keyTafsirPrefix}$surahNumber');
        }
      }
      throw Exception('التفسير غير محمل مسبقاً لهذه السورة');
    }
  }

  Future<AzkarResponse> getAzkar() async {
    try {
      final response = await http.get(Uri.parse(_azkarUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyAzkar, decodedBody);
        return AzkarResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyAzkar);
      if (localData != null) {
        try {
          return AzkarResponse.fromJson(json.decode(localData));
        } catch (_) {
          await _cacheService.removeData(CacheService.keyAzkar);
        }
      }
      throw Exception('الأذكار غير متوفرة بدون إنترنت');
    }
  }

  // الدوال الأخرى (Hadith) يمكن تطبيق نفس المنطق عليها إذا لزم الأمر
  Future<HadithResponse> getHadiths(String book, int page) async {
    final response = await http.get(Uri.parse('$_hadithBaseUrl/$book?page=$page')).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return HadithResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Hadiths');
    }
  }

  Future<dynamic> getSurahsList() async {
    try {
      final response = await http.get(Uri.parse(_surahsListUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final dynamic data = json.decode(decodedBody);
        if (data is Map && data.containsKey('value')) {
          await _cacheService.saveData(CacheService.keySurahsList, json.encode(data['value']));
          return data['value'];
        }
        await _cacheService.saveData(CacheService.keySurahsList, decodedBody);
        return data;
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keySurahsList);
      if (localData != null) {
        try {
          return json.decode(localData);
        } catch (_) {
          await _cacheService.removeData(CacheService.keySurahsList);
        }
      }
      return [];
    }
  }
}

