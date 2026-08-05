import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/models/duas_model.dart';
import 'package:islami/services/cache_service.dart';

class ApiService {
  static const String _prayerBaseUrl = 'https://quran.yousefheiba.com/api/getPrayerTimes';
  static const String _quranBaseUrl = 'http://api.alquran.cloud/v1';
  static const String _hadithBaseUrl = 'https://hadis-api-id.vercel.app/hadith';
  static const String _radioUrl = 'https://quran.yousefheiba.com/api/radio';
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
      final response = await http.get(Uri.parse('$_ayahsBySurahUrl$surahNumber'));
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
    final response = await http.get(Uri.parse(_laylatAlQadrUrl));
    if (response.statusCode == 200) {
      return json.decode(utf8.decode(response.bodyBytes));
    }
    throw Exception('Failed to load data');
  }

  Future<Map<String, dynamic>> getReciterAudio(int reciterId) async {
    try {
      final response = await http.get(Uri.parse('$_recitersUrl$reciterId'));
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
      final response = await http.get(Uri.parse(_prayerBaseUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyPrayerTimes, decodedBody);
        return PrayerTimes.fromJson(json.decode(decodedBody));
      }
      throw Exception('Failed to load from server');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyPrayerTimes);
      if (localData != null) {
        return PrayerTimes.fromJson(json.decode(localData));
      }
      throw Exception('لا يوجد اتصال بالإنترنت ولا توجد بيانات محفوظة');
    }
  }

  Future<SurahApiResponse> getSurah(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$_quranBaseUrl/surah/$surahNumber'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveSurah(surahNumber, decodedBody);
        return SurahApiResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getSurah(surahNumber);
      if (localData != null) {
        return SurahApiResponse.fromJson(json.decode(localData));
      }
      throw Exception('هذه السورة غير محملة مسبقاً، يرجى الاتصال بالإنترنت');
    }
  }

  Future<DuasResponse> getDuas() async {
    try {
      final response = await http.get(Uri.parse(_duasUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyDuas, decodedBody);
        return DuasResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyDuas);
      if (localData != null) {
        return DuasResponse.fromJson(json.decode(localData));
      }
      throw Exception('الأدعية غير متوفرة حالياً بدون إنترنت');
    }
  }

  Future<TafsirResponse> getTafsir(int surahNumber) async {
    try {
      final response = await http.get(Uri.parse('$_tafsirBaseUrl/$surahNumber'));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveTafsir(surahNumber, decodedBody);
        return TafsirResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getTafsir(surahNumber);
      if (localData != null) {
        return TafsirResponse.fromJson(json.decode(localData));
      }
      throw Exception('التفسير غير محمل مسبقاً لهذه السورة');
    }
  }

  Future<AzkarResponse> getAzkar() async {
    try {
      final response = await http.get(Uri.parse(_azkarUrl));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        await _cacheService.saveData(CacheService.keyAzkar, decodedBody);
        return AzkarResponse.fromJson(json.decode(decodedBody));
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getData(CacheService.keyAzkar);
      if (localData != null) {
        return AzkarResponse.fromJson(json.decode(localData));
      }
      throw Exception('الأذكار غير متوفرة بدون إنترنت');
    }
  }

  // الدوال الأخرى (Hadith, Radio) يمكن تطبيق نفس المنطق عليها إذا لزم الأمر
  Future<HadithResponse> getHadiths(String book, int page) async {
    final response = await http.get(Uri.parse('$_hadithBaseUrl/$book?page=$page'));
    if (response.statusCode == 200) {
      return HadithResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Hadiths');
    }
  }

  Future<dynamic> getSurahsList() async {
    try {
      final response = await http.get(Uri.parse(_surahsListUrl));
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
      if (localData != null) return json.decode(localData);
      return [];
    }
  }

  Future<RadioResponse> getRadios() async {
    try {
      final response = await http.get(Uri.parse(_radioUrl));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(utf8.decode(response.bodyBytes));
        
        // إذا كانت البيانات قائمة من الإذاعات
        if (data is List) {
          return RadioResponse(radios: data.map((e) => RadioItem.fromJson(e as Map<String, dynamic>)).toList());
        } 
        // إذا كان كائن يحتوي على مفتاح 'radios'
        else if (data is Map && data.containsKey('radios')) {
          var list = data['radios'] as List;
          return RadioResponse(radios: list.map((e) => RadioItem.fromJson(e as Map<String, dynamic>)).toList());
        }
        // إذا كان كائن يمثل إذاعة واحدة مباشرة (يحتوي على url)
        else if (data is Map && data.containsKey('url')) {
          return RadioResponse(radios: [
            RadioItem(
              id: int.tryParse(data['id']?.toString() ?? '1') ?? 1,
              name: data['name'] ?? "إذاعة القرآن الكريم من القاهرة",
              url: data['url'],
            )
          ]);
        }
      }
    } catch (e) {
      debugPrint("Radio API parsing error: $e");
    }
    
    // كحل أخير إذا فشل الـ API أو كان الرابط هو البث المباشر نفسه
    return RadioResponse(radios: [
      RadioItem(id: 1, name: "إذاعة القرآن الكريم من القاهرة", url: _radioUrl)
    ]);
  }
}

