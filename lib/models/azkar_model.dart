class AzkarResponse {
  final List<AzkarCategory> categories;

  AzkarResponse({required this.categories});

  factory AzkarResponse.fromJson(Map<String, dynamic> json) {
    List<AzkarCategory> list = [];
    json.forEach((key, value) {
      list.add(AzkarCategory(
        categoryName: key,
        azkar: (value as List).map((i) => AzkarItem.fromJson(i)).toList(),
      ));
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
      zekr: json['zekr'] ?? "",
      count: json['count'] ?? "1",
      description: json['description'] ?? "",
    );
  }
}
