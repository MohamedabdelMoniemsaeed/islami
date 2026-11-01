import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:islami/models/radio_model.dart';
import 'package:islami/services/cache_service.dart';

// اختبار حفظ/قراءة المفضلة — نفس المسار اللي بيعمله radio.dart
// (json.encode للـ Set، وقراءة json.decode + whereType<int>)
void main() {
  const stations = <RadioItem>[
    RadioItem(id: 1, name: 'القاهرة', url: 'https://example.com/1'),
    RadioItem(id: 4, name: 'البحرين', url: 'https://example.com/4'),
    RadioItem(id: 12, name: 'مختارات', url: 'https://example.com/12'),
  ];

  test('المفضلة محفوظة وتعمل نفس الترتيب اللي في radio.dart', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = CacheService();

    // نفس منطق _toggleFavorite في radio.dart
    final favorites = <int>{1, 4, 12};
    await cache.saveData(CacheService.keyRadioFavorites, json.encode(favorites.toList()));

    // نفس منطق _loadFavorites في radio.dart
    final data = await cache.getData(CacheService.keyRadioFavorites);
    final loaded = json.decode(data!).whereType<int>().toSet();

    expect(loaded, favorites);

    // المفضلة تظهر أول القائمة، والباقي بعدها
    final pinned = stations.where((r) => loaded.contains(r.id)).toList();
    expect(pinned.map((r) => r.id), [1, 4, 12]);
  });

  test('لو مفيش مفضلة محفوظة ترجع null مش خطأ', () async {
    SharedPreferences.setMockInitialValues({});
    final cache = CacheService();
    final data = await cache.getData(CacheService.keyRadioFavorites);
    expect(data, isNull);
  });
}
