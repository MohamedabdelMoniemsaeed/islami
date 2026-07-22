class RadioResponse {
  final List<RadioItem> radios;

  RadioResponse({required this.radios});

  factory RadioResponse.fromJson(Map<String, dynamic> json) {
    var list = json['radios'] as List;
    List<RadioItem> radioList = list.map((i) => RadioItem.fromJson(i)).toList();
    return RadioResponse(radios: radioList);
  }
}

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
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }
}
