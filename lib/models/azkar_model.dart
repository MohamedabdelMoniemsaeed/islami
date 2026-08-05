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
        list.add(AzkarCategory(
          categoryName: categoryNames[key] ?? key,
          azkar: value.map((i) => AzkarItem.fromJson(i)).toList(),
        ));
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

  AzkarItem({
    required this.zekr,
    required this.count,
    required this.description,
  });

  factory AzkarItem.fromJson(Map<String, dynamic> json) {
    return AzkarItem(
      zekr: json['text'] ?? "",
      count: (json['count'] ?? 1).toString(),
      description: "",
    );
  }
}
