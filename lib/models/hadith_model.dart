class HadithResponse {
  final String name;
  final String slug;
  final int total;
  final List<HadithItem> items;

  HadithResponse({
    required this.name,
    required this.slug,
    required this.total,
    required this.items,
  });

  factory HadithResponse.fromJson(Map<String, dynamic> json) {
    var list = json['items'] as List;
    List<HadithItem> hadithList = list.map((i) => HadithItem.fromJson(i)).toList();

    return HadithResponse(
      name: json['name'],
      slug: json['slug'],
      total: json['total'],
      items: hadithList,
    );
  }
}

class HadithItem {
  final int number;
  final String arab;
  final String id;

  HadithItem({
    required this.number,
    required this.arab,
    required this.id,
  });

  factory HadithItem.fromJson(Map<String, dynamic> json) {
    return HadithItem(
      number: json['number'],
      arab: json['arab'],
      id: json['id'],
    );
  }
}
