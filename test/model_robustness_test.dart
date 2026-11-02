import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/models/radio_model.dart';

// يحديد حدود الأمان في fromJson: إيه اللي بيتحل من غير مشكلة وإيه اللي بيبقى
// Crash من payload ناقص أو تالف (مهم لأن الكاش التالف كمان بيعدي على نفس المسار).
void main() {
  group('PrayerTimes.fromJson', () {
    test('parses a full payload', () {
      final t = PrayerTimes.fromJson({
        'prayer_times': {'Fajr': '04:12', 'Dhuhr': '12:01'},
        'date': {
          'date_en': '2026-11-01',
          'date_hijri': {'date': '1448-06-20', 'weekday': {'ar': 'الثلاثاء'}},
        },
        'country': 'Egypt',
        'region': 'Cairo',
      });
      expect(t.fajr, '04:12');
      expect(t.dayAr, 'الثلاثاء');
      expect(t.isha, ''); // مفقود من prayer_times بيتعالج بـ ""
    });

    test('missing country/region default to empty strings', () {
      final t = PrayerTimes.fromJson({
        'prayer_times': {},
        'date': {'date_hijri': {'weekday': {}}},
      });
      expect(t.country, '');
      expect(t.region, '');
      expect(t.fajr, '');
    });

    test('missing weekday defaults to empty (crash surface fixed)', () {
      final t = PrayerTimes.fromJson({
        'prayer_times': {},
        'date': {
          'date_hijri': {'date': '1448-06-20'}
        },
      });
      expect(t.dayAr, '');
      expect(t.dateHijri, '1448-06-20');
    });
  });

  group('Other models', () {
    test('HadithResponse parses items', () {
      final response = HadithResponse.fromJson({
        'name': 'Abu Dawud',
        'slug': 'abu-dawud',
        'total': 1,
        'items': [
          {'number': 1, 'arab': 'الحمد لله', 'id': 'a1'},
        ],
      });
      expect(response.items.single.number, 1);
    });

    test('HadithResponse without items throws TypeError', () {
      expect(
        () => HadithResponse.fromJson({'name': 'x', 'slug': 'x', 'total': 0}),
        throwsA(isA<TypeError>()),
      );
    });

    test('RadioItem with a string id throws TypeError', () {
      expect(
        () => RadioItem.fromJson({'id': '5', 'name': 'n', 'url': 'u'}),
        throwsA(isA<TypeError>()),
      );
    });

    test('AzkarItem defaults count to 1 and empty description when missing',
        () {
      final item = AzkarItem.fromJson({'text': 'بسم الله'});
      expect(item.zekr, 'بسم الله');
      expect(item.count, '1');
      expect(item.description, '');
    });
  });
}
