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
      List<DuaItem> items = [];
      if (value is List) {
        for (var item in value) {
          if (item is List) {
            for (var subItem in item) {
              items.add(DuaItem.fromJson(subItem));
            }
          } else {
            items.add(DuaItem.fromJson(item));
          }
        }
      } else if (value is Map) {
        value.forEach((subKey, subVal) {
          if (subVal is List) {
            for (var subItem in subVal) {
              items.add(DuaItem.fromJson(subItem));
            }
          }
        });
      }
      if (items.isNotEmpty) {
        list.add(DuasCategory(
          categoryName: categoryNames[key] ?? key,
          duas: items,
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

  factory DuaItem.fromJson(dynamic json) {
    if (json is String) {
      return DuaItem(text: json, count: "1");
    }
    if (json is Map<String, dynamic>) {
      return DuaItem(
        text: json['text'] ?? json['content'] ?? json['zekr'] ?? json['dua'] ?? "",
        count: (json['count'] ?? 1).toString(),
      );
    }
    return DuaItem(text: json.toString(), count: "1");
  }
}
