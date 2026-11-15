import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/radio_model.dart';

void main() {
  group('Radio Stations Tests', () {
    const List<RadioItem> islamicRadios = [
      RadioItem(id: 1, name: 'إذاعة القرآن الكريم من القاهرة', url: 'https://stream.mp3quran.net/quran'),
      RadioItem(id: 2, name: 'راديو القرآن – محمد صديق المنشاوي', url: 'https://stream.mp3quran.net/minshawi'),
      RadioItem(id: 3, name: 'إذاعة القرآن الكريم – مختارات تلاوات', url: 'https://stream.mp3quran.net/mix'),
      RadioItem(id: 4, name: 'إذاعة تراتيل قصار السور', url: 'https://stream.mp3quran.net/tarateel'),
      RadioItem(id: 5, name: 'راديو القرآن – عبد الباسط عبد الصمد (المجود)', url: 'https://stream.mp3quran.net/abdulbasit_mojawwad'),
      RadioItem(id: 6, name: 'راديو القرآن – محمود خليل الحصري', url: 'https://stream.mp3quran.net/hussary'),
      RadioItem(id: 7, name: 'راديو القرآن – محمد محمود الطبلاوي', url: 'https://stream.mp3quran.net/tablawy'),
      RadioItem(id: 8, name: 'راديو القرآن – مشاري راشد العفاسي', url: 'https://stream.mp3quran.net/mishary'),
      RadioItem(id: 9, name: 'راديو القرآن – سعود الشريم', url: 'https://stream.mp3quran.net/shuraim'),
      RadioItem(id: 10, name: 'إذاعة القرآن الكريم من مكة المكرمة', url: 'https://stream.mp3quran.net/makkah'),
      RadioItem(id: 11, name: 'إذاعة القرآن الكريم من المدينة المنورة', url: 'https://stream.mp3quran.net/madinah'),
      RadioItem(id: 12, name: 'إذاعة تفسير القرآن الكريم', url: 'https://stream.mp3quran.net/tafseer'),
      RadioItem(id: 13, name: 'إذاعة الرقية الشرعية', url: 'https://stream.mp3quran.net/roqiah'),
    ];

    test('all radio stations have unique IDs and valid HTTPS URLs', () {
      final ids = islamicRadios.map((r) => r.id).toSet();
      expect(ids.length, islamicRadios.length);

      for (var radio in islamicRadios) {
        expect(radio.name.isNotEmpty, isTrue);
        expect(radio.url.startsWith('https://'), isTrue);
      }
    });

    test('includes Cairo Quran Radio at the top', () {
      expect(islamicRadios[0].name, 'إذاعة القرآن الكريم من القاهرة');
      expect(islamicRadios[0].url, 'https://stream.mp3quran.net/quran');
    });

    test('includes Sheikh Al-Minshawi dedicated live stream radio', () {
      final minshawiRadio = islamicRadios.firstWhere(
        (r) => r.name.contains('المنشاوي'),
      );
      expect(minshawiRadio.url, 'https://stream.mp3quran.net/minshawi');
    });
  });
}
