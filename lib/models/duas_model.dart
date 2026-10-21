class DuaItem {
  final String title;
  final String content;

  DuaItem({required this.title, required this.content});

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      title: json['title'] ?? '',
      content: json['content'] ?? json['text'] ?? '',
    );
  }
}

class DuasResponse {
  final List<DuaItem> duas;

  DuasResponse({required this.duas});

  factory DuasResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['duas'] ?? json['data'] ?? []) as List;
    List<DuaItem> items = list.map((i) => DuaItem.fromJson(i)).toList();
    return DuasResponse(duas: items);
  }
}
