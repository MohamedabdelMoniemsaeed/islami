class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;
  final int page;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.page,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      text: json['text'] ?? '',
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 1,
      page: json['page'] ?? 1,
    );
  }
}

class SurahApiResponse {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final List<Ayah> ayahs;

  SurahApiResponse({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.ayahs,
  });

  factory SurahApiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? json;
    var ayahsList = (data['ayahs'] ?? []) as List;
    List<Ayah> parsedAyahs = ayahsList.map((a) => Ayah.fromJson(a)).toList();
    return SurahApiResponse(
      number: data['number'] ?? 1,
      name: data['name'] ?? '',
      englishName: data['englishName'] ?? '',
      revelationType: data['revelationType'] ?? 'Meccan',
      ayahs: parsedAyahs,
    );
  }
}
