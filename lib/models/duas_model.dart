class DuasResponse {
  final List<DuasCategory> categories;

  DuasResponse({required this.categories});

  static const Map<String, String> categoryNames = {
    "prophetic_duas": "أدعية نبوية",
    "quran_duas": "أدعية قرآنية",
    "prophets_duas": "أدعية الأنبياء",
    "quran_completion_duas": "دعاء ختم القرآن",
  };

  factory DuasResponse.fromJson(Map<String, dynamic> json) {
    List<DuasCategory> list = [];
    json.forEach((key, value) {
      if (value is List) {
        list.add(DuasCategory(
          categoryName: categoryNames[key] ?? key,
          duas: value.map((i) => DuaItem.fromJson(i)).toList(),
        ));
      }
    });
    return DuasResponse(categories: list);
  }
}

class DuasCategory {
  final String categoryName;
  final List<DuaItem> duas;

  DuasCategory({required this.categoryName, required this.duas});
}

class DuaItem {
  final String text;
  final String count;

  DuaItem({
    required this.text,
    required this.count,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      text: json['text'] ?? "",
      count: (json['count'] ?? 1).toString(),
    );
  }
}
