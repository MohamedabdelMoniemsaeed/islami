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
    // json.decode يرجع Map<String, dynamic> بالداخل، بس كنّا آمنين لو
    // وصلنا أي نوع Map عشان ما يعملناش cast exception.
    Map<String, dynamic> pick(dynamic value) =>
        value is Map ? value.cast<String, dynamic>() : {};

    final prayerTimes = pick(json['prayer_times']);
    final date = pick(json['date']);
    final hijri = pick(date['date_hijri']);
    final weekday = pick(hijri['weekday']);

    return PrayerTimes(
      fajr: prayerTimes['Fajr'] ?? "",
      sunrise: prayerTimes['Sunrise'] ?? "",
      dhuhr: prayerTimes['Dhuhr'] ?? "",
      asr: prayerTimes['Asr'] ?? "",
      maghrib: prayerTimes['Maghrib'] ?? "",
      isha: prayerTimes['Isha'] ?? "",
      dateEn: date['date_en'] ?? "",
      dateHijri: hijri['date'] ?? "",
      dayAr: weekday['ar'] ?? "",
      country: json['country'] ?? "",
      region: json['region'] ?? "",
    );
  }
}
