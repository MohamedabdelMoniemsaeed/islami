class TafsirItem {
  final int sura;
  final int aya;
  final String arabicText;
  final String translation;

  TafsirItem({
    required this.sura,
    required this.aya,
    required this.arabicText,
    required this.translation,
  });

  factory TafsirItem.fromJson(Map<String, dynamic> json) {
    return TafsirItem(
      sura: int.tryParse(json['sura']?.toString() ?? '1') ?? 1,
      aya: int.tryParse(json['aya']?.toString() ?? '1') ?? 1,
      arabicText: json['arabic_text'] ?? json['text'] ?? '',
      translation: json['translation'] ?? '',
    );
  }
}

class TafsirResponse {
  final List<TafsirItem> result;

  TafsirResponse({required this.result});

  factory TafsirResponse.fromJson(Map<String, dynamic> json) {
    var list = (json['result'] ?? json['data'] ?? []) as List;
    List<TafsirItem> items = list.map((i) => TafsirItem.fromJson(i)).toList();
    return TafsirResponse(result: items);
  }
}
