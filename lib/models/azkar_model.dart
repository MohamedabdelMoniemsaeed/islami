class AzkarResponse {
  final List<AzkarCategory> categories;

  AzkarResponse({required this.categories});

  static const Map<String, String> categoryNames = {
    "morning_azkar": "أذكار الصباح",
    "evening_azkar": "أذكار المساء",
    "prayer_azkar": "أذكار الصلاة",
    "prayer_later_azkar": "بعد الصلاة",
    "sleep_azkar": "أذكار النوم",
    "wake_up_azkar": "أذكار الاستيقاظ",
    "mosque_azkar": "أذكار المسجد",
    "miscellaneous_azkar": "أذكار متنوعة",
    "adhan_azkar": "أذكار الأذان",
    "wudu_azkar": "أذكار الوضوء",
    "home_azkar": "أذكار المنزل",
    "khala_azkar": "أذكار الخلاء",
    "food_azkar": "أذكار الطعام",
    "hajj_and_umrah_azkar": "أذكار الحج والعمرة",
  };

  factory AzkarResponse.fromJson(Map<String, dynamic> json) {
    List<AzkarCategory> list = [];
    json.forEach((key, value) {
      if (value is List) {
        List<AzkarItem> items = [];
        for (var el in value) {
          if (el is List) {
            for (var sub in el) {
              if (sub is Map<String, dynamic>) {
                items.add(AzkarItem.fromJson(sub));
              }
            }
          } else if (el is Map<String, dynamic>) {
            items.add(AzkarItem.fromJson(el));
          }
        }
        if (items.isNotEmpty) {
          list.add(AzkarCategory(
            categoryName: categoryNames[key] ?? key,
            azkar: items,
          ));
        }
      }
    });
    return AzkarResponse(categories: list);
  }
}

class AzkarCategory {
  final String categoryName;
  final List<AzkarItem> azkar;

  AzkarCategory({required this.categoryName, required this.azkar});
}

class AzkarItem {
  final String zekr;
  final String count;
  final String description;
  final String reference;

  AzkarItem({
    required this.zekr,
    required this.count,
    required this.description,
    this.reference = '',
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    final rawCount = json['count'];
    String parsedCount = '1';
    if (rawCount != null) {
      final s = rawCount.toString().trim();
      if (s.isNotEmpty && s != '0') {
        parsedCount = s;
      }
    }
    return AzkarItem(
      zekr: (json['content'] ?? json['text'] ?? "").toString().trim(),
      count: parsedCount,
      description: (json['description'] ?? "").toString().trim(),
      reference: (json['reference'] ?? "").toString().trim(),
    );
  }
}
