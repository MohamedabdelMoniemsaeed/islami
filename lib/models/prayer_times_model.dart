class PrayerTimes {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String dateEn;
  final String dateHijri;
  final String dayAr;
  final String country;
  final String region;

  PrayerTimes({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.dateEn,
    required this.dateHijri,
    required this.dayAr,
    required this.country,
    required this.region,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final prayerTimes = json['prayer_times'];
    final date = json['date'];
    final hijri = date['date_hijri'];

    return PrayerTimes(
      fajr: prayerTimes['Fajr'] ?? "",
      sunrise: prayerTimes['Sunrise'] ?? "",
      dhuhr: prayerTimes['Dhuhr'] ?? "",
      asr: prayerTimes['Asr'] ?? "",
      maghrib: prayerTimes['Maghrib'] ?? "",
      isha: prayerTimes['Isha'] ?? "",
      dateEn: date['date_en'] ?? "",
      dateHijri: hijri['date'] ?? "",
      dayAr: hijri['weekday']['ar'] ?? "",
      country: json['country'] ?? "",
      region: json['region'] ?? "",
    );
  }
}
