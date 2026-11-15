import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islami/dezeen/sura_name.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/models/duas_model.dart';
import 'package:islami/services/cache_service.dart';

class ApiService {
  static const String _prayerBaseUrl = 'https://api.aladhan.com/v1/timings?latitude=30.0444&longitude=31.2357&method=4';
  static const String _quranBaseUrl = 'https://api.alquran.cloud/v1';
  static const String _hadithBaseUrl = 'https://hadis-api-id.vercel.app/hadith';
  static const String _surahsListUrl = 'https://api.alquran.cloud/v1/surah';
  // shortcut: Laylat Al Qadr API is down at yousefheiba.com, uses static fallback instead
  static const String _minshawiCdnBase = 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/';

  final CacheService _cacheService = CacheService();

  Future<List<dynamic>> getSurahsList() async {
    try {
      final response = await http.get(Uri.parse(_surahsListUrl)).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decodedBody = utf8.decode(response.bodyBytes);
        final Map<String, dynamic> data = json.decode(decodedBody);
        final List<dynamic> surahs = data['data'];
        await _cacheService.saveData(CacheService.keySurahsList, json.encode(surahs));
        return surahs;
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
      throw Exception('هذه السورة غير محملة مسبقاُ، يرجى الاتصال بالإنترنت');
    }
  }

  Future<TafsirResponse> getTafsir(int surahNumber) async {
    try {
      final tafsirRes = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/ar.jalalayn')).timeout(const Duration(seconds: 30));
      final quranRes = await http.get(Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/ar.quran-uthmani')).timeout(const Duration(seconds: 30));

      if (tafsirRes.statusCode == 200 && quranRes.statusCode == 200) {
        final tafsirData = json.decode(utf8.decode(tafsirRes.bodyBytes))['data'];
        final quranData = json.decode(utf8.decode(quranRes.bodyBytes))['data'];

        final List tafsirAyahs = tafsirData['ayahs'];
        final List quranAyahs = quranData['ayahs'];

        List<TafsirItem> items = [];
        for (int i = 0; i < tafsirAyahs.length; i++) {
          items.add(TafsirItem(
            sura: surahNumber.toString(),
            aya: tafsirAyahs[i]['numberInSurah'].toString(),
            arabicText: i < quranAyahs.length ? quranAyahs[i]['text'] : '',
            translation: tafsirAyahs[i]['text'],
          ));
        }

        final responseMap = {'result': items.map((e) => {
          'sura': e.sura,
          'aya': e.aya,
          'arabic_text': e.arabicText,
          'translation': e.translation,
        }).toList()};

        await _cacheService.saveTafsir(surahNumber, json.encode(responseMap));
        return TafsirResponse.fromJson(responseMap);
      }
      throw Exception('Server Error');
    } catch (e) {
      final localData = await _cacheService.getTafsir(surahNumber);
      if (localData != null) {
        try {
          return TafsirResponse.fromJson(json.decode(localData));
        } catch (_) {}
      }
      throw Exception('التفسير غير متوفر حالياَ');
    }
  }

  /// Laylat Al Qadr — static fallback since the old yousefheiba endpoint is down
  Future<Map<String, dynamic>> getLaylatAlQadr() async {
    return {
      'content':
        'ليلة القدر خير من ألف شهر، تنزل الملائكة والروح فيها بإذن ربهم من كل أمر، سلام هي حتى مطلع الفجر. هي ليلة مباركة اختارها الله سبحانه وتعالى، وقد أنزل الله فيها القرآن هدى للناس وبينات من الهدى والفرقان.',
    };
  }

  /// توليد قائمة تلاوات الشيخ محمد صديق المنشاوي من شبكة Mp3Quran الرسمية
  Future<Map<String, dynamic>> getReciterAudio(int reciterId) async {
    final List<Map<String, dynamic>> tracks = [];
    for (int i = 0; i < SuraName.listSuraName.length; i++) {
      final int surahId = i + 1;
      final String paddedId = surahId.toString().padLeft(3, '0');
      tracks.add({
        'surah_id': surahId.toString(),
        'surah_name_ar': 'سورة ${SuraName.listSuraName[i]}',
        'audio_url': '$_minshawiCdnBase$paddedId.mp3',
      });
    }
    return {
      'reciter_id': reciterId.toString(),
      'reciter_name': 'الشيخ محمد صديق المنشاوي',
      'audio_urls': tracks,
    };
  }

  Future<HadithResponse> getHadiths(String book, int page) async {
    final response = await http.get(Uri.parse('$_hadithBaseUrl/$book?page=$page'))
        .timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      return HadithResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Hadiths');
    }
  }

  Future<AzkarResponse> getAzkar() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/azkar.json');
      return AzkarResponse.fromJson(json.decode(jsonString));
    } catch (e) {
      return AzkarResponse(categories: []);
    }
  }

  Future<DuasResponse> getDuas() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/duas.json');
      return DuasResponse.fromJson(json.decode(jsonString));
    } catch (e) {
      return DuasResponse(categories: []);
    }
  }
}
