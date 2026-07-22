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
    var data = json['data'];
    var list = data['ayahs'] as List;
    List<Ayah> ayahList = list.map((i) => Ayah.fromJson(i)).toList();

    return SurahApiResponse(
      number: data['number'],
      name: data['name'],
      englishName: data['englishName'],
      revelationType: data['revelationType'],
      ayahs: ayahList,
    );
  }
}

class Ayah {
  final int number;
  final String text;
  final int numberInSurah;
  final int juz;

  Ayah({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      text: json['text'],
      numberInSurah: json['numberInSurah'],
      juz: json['juz'],
    );
  }
}
