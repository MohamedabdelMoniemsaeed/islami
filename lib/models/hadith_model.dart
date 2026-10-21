class HadithItem {
  final int number;
  final String arabic;
  final String translation;

  HadithItem({
    required this.number,
    required this.arabic,
    required this.translation,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      number: json['number'] ?? 0,
      arabic: json['arab'] ?? json['arabic'] ?? '',
      translation: json['id'] ?? json['translation'] ?? '',
    );
  }
}

class HadithResponse {
  final String name;
  final int total;
  final List<HadithItem> items;

  HadithResponse({
    required this.name,
    required this.total,
    required this.items,
  });

  factory HadithResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['items'] ?? json['data'] ?? []) as List;
    List<HadithItem> itemsList = list.map((i) => HadithItem.fromJson(i)).toList();
    return HadithResponse(
      name: json['name'] ?? '',
      total: json['total'] ?? itemsList.length,
      items: itemsList,
    );
  }
}
