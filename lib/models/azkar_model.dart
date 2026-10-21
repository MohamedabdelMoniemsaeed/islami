class ZikrItem {
  final String category;
  final String count;
  final String description;
  final String reference;

  ZikrItem({
    required this.category,
    required this.count,
    required this.description,
    required this.reference,
  });

  factory ZikrItem.fromJson(Map<String, dynamic> json) {
    return ZikrItem(
      category: json['category'] ?? '',
      count: json['count']?.toString() ?? '1',
      description: json['description'] ?? json['text'] ?? '',
      reference: json['reference'] ?? '',
    );
  }
}

class AzkarResponse {
  final List<ZikrItem> azkar;

  AzkarResponse({required this.azkar});

  factory AzkarResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['azkar'] ?? json['data'] ?? []) as List;
    List<ZikrItem> items = list.map((i) => ZikrItem.fromJson(i)).toList();
    return AzkarResponse(azkar: items);
  }
}
