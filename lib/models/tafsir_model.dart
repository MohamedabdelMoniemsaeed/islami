class TafsirResponse {
  final List<TafsirItem> result;

  TafsirResponse({required this.result});

  factory TafsirResponse.fromJson(Map<String, dynamic> json) {
    var list = json['result'] as List;
    List<TafsirItem> tafsirList = list.map((i) => TafsirItem.fromJson(i)).toList();
    return TafsirResponse(result: tafsirList);
  }
}

class TafsirItem {
  final String sura;
  final String aya;
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
      sura: json['sura'],
      aya: json['aya'],
      arabicText: json['arabic_text'],
      translation: json['translation'],
    );
  }
}
