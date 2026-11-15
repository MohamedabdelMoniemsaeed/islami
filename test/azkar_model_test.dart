import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/azkar_model.dart';

void main() {
  group('AzkarModel Tests', () {
    test('parses assets/azkar.json accurately with flattened categories and items', () {
      final file = File('assets/azkar.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = AzkarResponse.fromJson(jsonMap);

      expect(response.categories.isNotEmpty, isTrue);
      // تأكد من وجود التصنيفات الأساسية
      final names = response.categories.map((c) => c.categoryName).toList();
      expect(names, contains('أذكار الصباح'));
      expect(names, contains('أذكار المساء'));
      expect(names, contains('أذكار النوم'));

      // فحص تصنيف أذكار الصباح
      final morning = response.categories.firstWhere((c) => c.categoryName == 'أذكار الصباح');
      expect(morning.azkar.isNotEmpty, isTrue);
      expect(morning.azkar.first.zekr.isNotEmpty, isTrue);
      expect(int.parse(morning.azkar.first.count) >= 1, isTrue);
    });

    test('handles both flat and nested JSON lists robustly', () {
      final mockData = {
        'أذكار مخصصة': [
          [
            {'content': 'سبحان الله وبحمده', 'count': '100', 'description': 'فضل عظيم', 'reference': 'مسلم'},
          ],
          {'content': 'لا إله إلا الله', 'count': '10', 'description': ''},
        ]
      };

      final response = AzkarResponse.fromJson(mockData);
      expect(response.categories.length, 1);
      final cat = response.categories.first;
      expect(cat.azkar.length, 2);
      expect(cat.azkar[0].zekr, 'سبحان الله وبحمده');
      expect(cat.azkar[0].count, '100');
      expect(cat.azkar[0].reference, 'مسلم');
      expect(cat.azkar[1].zekr, 'لا إله إلا الله');
      expect(cat.azkar[1].count, '10');
    });
  });
}
