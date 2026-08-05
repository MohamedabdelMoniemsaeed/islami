import 'package:flutter_test/flutter_test.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/models/tafsir_model.dart';

void main() {
  group('ApiService Integration Tests', () {
    final apiService = ApiService();

    test('Fetch Prayer Times successfully', () async {
      final prayerTimes = await apiService.getPrayerTimes();
      expect(prayerTimes, isA<PrayerTimes>());
      expect(prayerTimes.fajr, isNotEmpty);
      print('✓ Prayer Times OK: Fajr is ${prayerTimes.fajr}');
    });

    test('Fetch Surah 114 (An-Nas) successfully', () async {
      final surah = await apiService.getSurah(114);
      expect(surah, isA<SurahApiResponse>());
      expect(surah.name, contains('النَّاس'));
      print('✓ Quran API OK: Surah ${surah.name} has ${surah.ayahs.length} ayahs');
    });

    test('Fetch Hadiths from Abu Dawud successfully', () async {
      final hadithData = await apiService.getHadiths('abu-dawud', 2);
      expect(hadithData, isA<HadithResponse>());
      expect(hadithData.items, isNotEmpty);
      print('✓ Hadith API OK: Found ${hadithData.items.length} hadiths');
    });

    test('Fetch Radios successfully', () async {
      final radioData = await apiService.getRadios();
      expect(radioData, isA<RadioResponse>());
      expect(radioData.radios, isNotEmpty);
      print('✓ Radio API OK: Found ${radioData.radios.length} radio stations');
    });

    test('Fetch Tafsir for Surah 114 successfully', () async {
      final tafsirData = await apiService.getTafsir(114);
      expect(tafsirData, isA<TafsirResponse>());
      expect(tafsirData.result, isNotEmpty);
      expect(tafsirData.result.first.arabicText, contains('قُلْ أَعُوذُ بِرَبِّ النَّاسِ'));
      print('✓ Tafsir API OK: Found interpretation for Surah ${tafsirData.result.first.sura}');
    });
  });
}
