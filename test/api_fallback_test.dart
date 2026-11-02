import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/cache_service.dart';

// في التست رانر، أي suite تنشئ HttpClient: كل طلب HTTP يرجع 400 من غير نت
// (سلوك flutter_test)، ففرع الـ catch شغال determinstic من غير شبكة.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const prayerTimesJson = <String, dynamic>{
    'prayer_times': {
      'Fajr': '04:12',
      'Sunrise': '05:40',
      'Dhuhr': '12:01',
      'Asr': '15:25',
      'Maghrib': '17:02',
      'Isha': '18:15',
    },
    'date': {
      'date_en': '2026-11-01',
      'date_hijri': {'date': '1448-06-20', 'weekday': {'ar': 'الثلاثاء'}},
    },
    'country': 'Egypt',
    'region': 'Cairo',
  };

  const surah114Json = <String, dynamic>{
    'data': {
      'number': 114,
      'name': 'النَّاس',
      'englishName': 'An-Nas',
      'revelationType': 'Meccan',
      'ayahs': [
        {'number': 756, 'text': 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', 'numberInSurah': 1, 'juz': 30},
      ],
    },
  };

  group('ApiService offline fallback (cache)', () {
    test('cached prayer times are returned when the network fails', () async {
      SharedPreferences.setMockInitialValues({
        CacheService.keyPrayerTimes: jsonEncode(prayerTimesJson),
      });
      final times = await ApiService().getPrayerTimes();
      expect(times.fajr, '04:12');
      expect(times.country, 'Egypt');
    });

    test('cached surah 114 is returned when the network fails', () async {
      SharedPreferences.setMockInitialValues({
        '${CacheService.keySurahPrefix}114': jsonEncode(surah114Json),
      });
      final surah = await ApiService().getSurah(114);
      expect(surah.name, 'النَّاس');
      expect(surah.ayahs.single.numberInSurah, 1);
    });

    test('corrupt cache JSON propagates a FormatException (crash surface)', () async {
      // يوثّق السلوك الحالي: الكاش التالف بيبقى بيحط التطبيق في استثناء مش رسالة واضحة
      SharedPreferences.setMockInitialValues({
        CacheService.keyPrayerTimes: '{"broken":',
      });
      await expectLater(
        ApiService().getPrayerTimes(),
        throwsA(isA<FormatException>()),
      );
    });

    test('no cache and no network throws a clear error', () async {
      SharedPreferences.setMockInitialValues({});
      Object? error;
      try {
        await ApiService().getPrayerTimes();
      } catch (e) {
        error = e;
      }
      expect(error, isA<Exception>());
      expect(error.toString(), contains('لا يوجد اتصال'));
    });
  });
}
