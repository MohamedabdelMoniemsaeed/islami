import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/radio_model.dart';

class ApiService {
  static const String _prayerBaseUrl = 'https://api.aladhan.com/v1';
  static const String _quranBaseUrl = 'http://api.alquran.cloud/v1';
  static const String _hadithBaseUrl = 'https://hadis-api-id.vercel.app/hadith';
  static const String _radioUrl = 'https://www.mp3quran.net/api/v3/radios?language=ar';

  Future<PrayerTimes> getPrayerTimes(String city, String country) async {
    final response = await http.get(
      Uri.parse('$_prayerBaseUrl/timingsByCity?city=$city&country=$country'),
    );

    if (response.statusCode == 200) {
      return PrayerTimes.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  Future<SurahApiResponse> getSurah(int surahNumber) async {
    final response = await http.get(
      Uri.parse('$_quranBaseUrl/surah/$surahNumber'),
    );

    if (response.statusCode == 200) {
      return SurahApiResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Surah');
    }
  }

  Future<HadithResponse> getHadiths(String book, int page) async {
    final response = await http.get(
      Uri.parse('$_hadithBaseUrl/$book?page=$page'),
    );

    if (response.statusCode == 200) {
      return HadithResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load Hadiths');
    }
  }

  Future<RadioResponse> getRadios() async {
    final response = await http.get(Uri.parse(_radioUrl));

    if (response.statusCode == 200) {
      return RadioResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Failed to load Radios');
    }
  }
}
