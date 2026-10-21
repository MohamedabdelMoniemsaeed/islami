class RadioItem {
  final int id;
  final String name;
  final String url;

  RadioItem({
    required this.id,
    required this.name,
    required this.url,
  });

  factory RadioItem.fromJson(Map<String, dynamic> json) {
    return RadioItem(
      id: int.tryParse(json['id']?.toString() ?? '1') ?? 1,
      name: json['name'] ?? 'إذاعة القرآن الكريم',
      url: json['url'] ?? '',
    );
  }
}

class RadioResponse {
  final List<RadioItem> radios;

  RadioResponse({required this.radios});
}
