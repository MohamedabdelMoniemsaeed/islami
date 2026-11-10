import 'package:flutter_test/flutter_test.dart';
import 'package:islami/services/api_service.dart';

void main() {
  group('ApiService Reciter & Audio Tests', () {
    final apiService = ApiService();

    test('getReciterAudio returns all 114 surahs for Minshawi from official CDN', () async {
      final data = await apiService.getReciterAudio(112);

      expect(data['reciter_id'], '112');
      expect(data['reciter_name'], 'الشيخ محمد صديق المنشاوي');

      final List<dynamic> tracks = data['audio_urls'];
      expect(tracks.length, 114);

      // اختبار السورة الأولى (الفاتحة)
      expect(tracks[0]['surah_id'], '1');
      expect(tracks[0]['surah_name_ar'], 'سورة الفاتحه');
      expect(tracks[0]['audio_url'], 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/001.mp3');

      // اختبار سورة البقرة
      expect(tracks[1]['surah_id'], '2');
      expect(tracks[1]['surah_name_ar'], 'سورة البقرة');
      expect(tracks[1]['audio_url'], 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/002.mp3');

      // اختبار السورة الأخيرة (الناس)
      expect(tracks[113]['surah_id'], '114');
      expect(tracks[113]['surah_name_ar'], 'سورة الناس');
      expect(tracks[113]['audio_url'], 'https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/114.mp3');
    });

    test('all audio URLs follow valid https structure and mp3 format', () async {
      final data = await apiService.getReciterAudio(112);
      final List<dynamic> tracks = data['audio_urls'];

      for (var track in tracks) {
        final String url = track['audio_url'];
        expect(url.startsWith('https://cdn.mp3quran.net/audio/muhammad-minshawi/r1/'), isTrue);
        expect(url.endsWith('.mp3'), isTrue);
      }
    });
  });
}
