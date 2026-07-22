import 'package:flutter_test/flutter_test.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/surah_api_model.dart';
import 'package:islami/models/radio_model.dart';

void main() {
  group('ApiService Integration Tests', () {
    final apiService = ApiService();

    test('Fetch Prayer Times successfully', () async {
      final prayerTimes = await apiService.getPrayerTimes('Cairo', 'Egypt');
      expect(prayerTimes, isA<PrayerTimes>());
      expect(prayerTimes.fajr, isNotEmpty);
      print('✓ Prayer Times OK: Fajr is ${prayerTimes.fajr}');
    });

    test('Fetch Surah 114 (An-Nas) successfully', () async {
      final surah = await apiService.getSurah(114);
      expect(surah, isA<SurahApiResponse>());
      expect(surah.name, contains('النَّاس'));
      expect(surah.ayahs.length, equals(6));
      print('✓ Quran API OK: Surah ${surah.name} has ${surah.ayahs.length} ayahs');
    });

    test('Fetch Hadiths from Abu Dawud successfully', () async {
      final hadithData = await apiService.getHadiths('abu-dawud', 2);
      expect(hadithData, isA<HadithResponse>());
      expect(hadithData.items, isNotEmpty);
      print('✓ Hadith API OK: Found ${hadithData.items.length} hadiths in ${hadithData.name}');
    });

    test('Fetch Radios successfully', () async {
      final radioData = await apiService.getRadios();
      expect(radioData, isA<RadioResponse>());
      expect(radioData.radios, isNotEmpty);
      print('✓ Radio API OK: Found ${radioData.radios.length} radio stations');
      print('✓ First Radio: ${radioData.radios.first.name}');
    });
   group('Radio API Specific Tests', () {
    test('Radio data has valid URLs', () async {
      final radioData = await apiService.getRadios();
      for (var radio in radioData.radios.take(5)) {
        expect(radio.url, startsWith('http'));
      }
      print('✓ Radio URLs format OK');
    });
  });
  });
}
