import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/duas_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Duas Model Tests', () {
    test('parses assets/duas.json accurately with cleaned categories and items', () {
      final file = File('assets/duas.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = json.decode(file.readAsStringSync()) as Map<String, dynamic>;
      final response = DuasResponse.fromJson(jsonMap);

      expect(response.categories.isNotEmpty, isTrue);
      final names = response.categories.map((c) => c.categoryName).toList();
      expect(names, contains('أدعية قرآنية'));
      expect(names, contains('أدعية الأنبياء'));
      expect(names, contains('أدعية نبوية'));
      expect(names, contains('دعاء ختم القرآن'));

      // Check Quranic duas
      final quranCategory = response.categories.firstWhere((c) => c.categoryName == 'أدعية قرآنية');
      expect(quranCategory.duas.isNotEmpty, isTrue);
      expect(quranCategory.duas.first.text, contains('رَبَّنَا آتِنَا'));
      expect(quranCategory.duas.first.text, isNot(contains(r'\n')));

      // Check Prophets duas
      final prophetsCategory = response.categories.firstWhere((c) => c.categoryName == 'أدعية الأنبياء');
      expect(prophetsCategory.duas.isNotEmpty, isTrue);
      expect(prophetsCategory.duas.first.text, contains('رَبَّنَا ظَلَمْنَا'));
      expect(prophetsCategory.duas.first.text, isNot(contains(r'\n')));
    });
  });
}
