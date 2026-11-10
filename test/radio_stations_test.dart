import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/radio_model.dart';

void main() {
  group('Radio Stations Tests', () {
    const List<RadioItem> islamicRadios = [
      RadioItem(id: 1, name: 'إذاعة القرآن الكريم من القاهرة', url: 'https://stream.radiojar.com/8s5u5tpdtwzuv'),
      RadioItem(id: 2, name: 'راديو القرآن – محمد صديق المنشاوي', url: 'https://qurango.net/radio/mohammed_siddiq_alminshawi'),
      RadioItem(id: 3, name: 'إذاعة القرآن الكريم – مختارات تلاوات', url: 'https://qurango.net/radio/mix'),
      RadioItem(id: 4, name: 'إذاعة تراتيل قصار السور', url: 'https://qurango.net/radio/tarateel'),
      RadioItem(id: 5, name: 'راديو القرآن – عبد الباسط عبد الصمد (المجود)', url: 'https://qurango.net/radio/abdulbasit_abdulsamad_mojawwad'),
      RadioItem(id: 6, name: 'راديو القرآن – محمود خليل الحصري', url: 'https://qurango.net/radio/mahmoud_khalil_alhussary'),
      RadioItem(id: 7, name: 'راديو القرآن – محمد محمود الطبلاوي', url: 'https://qurango.net/radio/mohammad_altablaway'),
      RadioItem(id: 8, name: 'راديو القرآن – مشاري راشد العفاسي', url: 'https://radio.mp3islam.com/listen/mishary/radio.mp3'),
      RadioItem(id: 9, name: 'راديو القرآن – سعود الشريم', url: 'https://radio.mp3islam.com/listen/alshuraim/radio.mp3'),
      RadioItem(id: 10, name: 'إذاعة القرآن الكريم – الشارقة', url: 'https://l3.itworkscdn.net/smcquranlive/quranradiolive/icecast.audio'),
      RadioItem(id: 11, name: 'إذاعة القرآن الكريم – الكويت', url: 'https://radio.mp3islam.com/listen/quran_radio/radio.mp3'),
      RadioItem(id: 12, name: 'إذاعة القرآن الكريم – البحرين', url: 'https://5c7b683162943.streamlock.net/live/ngrp:radio-106-1_all/playlist.m3u8'),
      RadioItem(id: 13, name: 'إذاعة القرآن الكريم – عُمَان', url: 'https://partwota.cdn.mgmlcdn.com/quranrdoorg/quranrdo.stream_aac/chunklist.m3u8'),
      RadioItem(id: 14, name: 'إذاعة القرآن الكريم – الأردن', url: 'https://jrtv-live.ercdn.net/jrradio/quranradio.m3u8'),
      RadioItem(id: 15, name: 'إذاعة القرآن الكريم من مكة المكرمة', url: 'https://radio.mp3islam.com/listen/makkah/radio.m3u8'),
      RadioItem(id: 16, name: 'إذاعة القرآن الكريم من المدينة المنورة', url: 'https://radio.mp3islam.com/listen/madinah/radio.m3u8'),
      RadioItem(id: 17, name: 'إذاعة تفسير القرآن الكريم', url: 'https://qurango.net/radio/tafseer'),
      RadioItem(id: 18, name: 'إذاعة الرقية الشرعية', url: 'https://qurango.net/radio/roqiah'),
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
      expect(islamicRadios[0].url, 'https://stream.radiojar.com/8s5u5tpdtwzuv');
    });

    test('includes Sheikh Al-Minshawi dedicated live stream radio', () {
      final minshawiRadio = islamicRadios.firstWhere(
        (r) => r.name.contains('المنشاوي'),
      );
      expect(minshawiRadio.url, 'https://qurango.net/radio/mohammed_siddiq_alminshawi');
    });
  });
}
