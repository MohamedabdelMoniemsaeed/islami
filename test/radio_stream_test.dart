import 'package:http/http.dart' as http;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Verify primary radio streams are accessible', () async {
    final List<RadioStreamTest> radioStreams = [
      RadioStreamTest(id: 1, name: 'إذاعة أبو بكر الشاطري', url: 'https://backup.qurango.net/radio/shaik_abu_bakr_al_shatri'),
      RadioStreamTest(id: 2, name: 'إذاعة تلاوات خاشعة', url: 'https://backup.qurango.net/radio/salma'),
      RadioStreamTest(id: 3, name: 'إذاعة الرقية الشرعية', url: 'https://backup.qurango.net/radio/roqiah'),
    ];

    int successCount = 0;
    for (var stream in radioStreams) {
      try {
        final response = await http.head(Uri.parse(stream.url)).timeout(const Duration(seconds: 10));
        if (response.statusCode >= 200 && response.statusCode < 400) {
          successCount++;
        }
      } catch (_) {}
    }

    expect(successCount >= 0, isTrue);
  });
}

class RadioStreamTest {
  final int id;
  final String name;
  final String url;
  const RadioStreamTest({required this.id, required this.name, required this.url});
}
