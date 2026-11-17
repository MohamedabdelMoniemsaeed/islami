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

  PrayerTimes copyWith({
    String? fajr,
    String? sunrise,
    String? dhuhr,
    String? asr,
    String? maghrib,
    String? isha,
    String? dateEn,
    String? dateHijri,
    String? dayAr,
    String? country,
    String? region,
  }) {
    return PrayerTimes(
      fajr: fajr ?? this.fajr,
      sunrise: sunrise ?? this.sunrise,
      dhuhr: dhuhr ?? this.dhuhr,
      asr: asr ?? this.asr,
      maghrib: maghrib ?? this.maghrib,
      isha: isha ?? this.isha,
      dateEn: dateEn ?? this.dateEn,
      dateHijri: dateHijri ?? this.dateHijri,
      dayAr: dayAr ?? this.dayAr,
      country: country ?? this.country,
      region: region ?? this.region,
    );
  }

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : null;

    final timings = (data != null && data['timings'] is Map<String, dynamic>)
        ? data['timings'] as Map<String, dynamic>
        : (json['prayer_times'] is Map<String, dynamic>
            ? json['prayer_times'] as Map<String, dynamic>
            : (json['timings'] is Map<String, dynamic>
                ? json['timings'] as Map<String, dynamic>
                : <String, dynamic>{}));

    final date = (data != null && data['date'] is Map<String, dynamic>)
        ? data['date'] as Map<String, dynamic>
        : (json['date'] is Map<String, dynamic>
            ? json['date'] as Map<String, dynamic>
            : <String, dynamic>{});

    final hijri = (date['hijri'] is Map<String, dynamic>)
        ? date['hijri'] as Map<String, dynamic>
        : (date['date_hijri'] is Map<String, dynamic>
            ? date['date_hijri'] as Map<String, dynamic>
            : (json['date_hijri'] is Map<String, dynamic>
                ? json['date_hijri'] as Map<String, dynamic>
                : <String, dynamic>{}));

    final weekday = hijri['weekday'] is Map<String, dynamic>
        ? hijri['weekday'] as Map<String, dynamic>
        : <String, dynamic>{};

    String rawDate = date['gregorian']?['date'] ??
        date['date_en'] ??
        date['date'] ??
        (json['date_en'] ?? "");

    // توحيد صيغة التاريخ إلى yyyy-MM-dd إذا كانت dd-MM-yyyy
    if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(rawDate)) {
      final parts = rawDate.split('-');
      rawDate = '${parts[2]}-${parts[1]}-${parts[0]}';
    }

    final meta = data != null && data['meta'] is Map<String, dynamic>
        ? data['meta'] as Map<String, dynamic>
        : (json['meta'] is Map<String, dynamic> ? json['meta'] as Map<String, dynamic> : null);

    String countryStr = (json['country'] ?? (data?['country'] ?? "مصر")).toString().trim();
    String regionStr = (json['region'] ?? (data?['region'] ?? "")).toString().trim();

    if (regionStr.isEmpty) {
      final meta = data != null && data['meta'] is Map<String, dynamic> ? data['meta'] : null;
      final lat = meta?['latitude'];
      final lon = meta?['longitude'];
      if (lat != null && lon != null) {
        if (lat > 30.4 && lat < 31.0 && lon > 31.3 && lon < 32.0) {
          regionStr = "الشرقية";
        } else if (lat > 29.9 && lat < 30.2 && lon > 31.1 && lon < 31.4) {
          regionStr = "القاهرة";
        } else {
          regionStr = "مصر";
        }
      } else {
        regionStr = "مصر";
      }
    }
    if (countryStr.isEmpty) countryStr = "مصر";

    return PrayerTimes(
      fajr: timings['Fajr'] ?? timings['fajr'] ?? "",
      sunrise: timings['Sunrise'] ?? timings['sunrise'] ?? "",
      dhuhr: timings['Dhuhr'] ?? timings['dhuhr'] ?? "",
      asr: timings['Asr'] ?? timings['asr'] ?? "",
      maghrib: timings['Maghrib'] ?? timings['maghrib'] ?? "",
      isha: timings['Isha'] ?? timings['isha'] ?? "",
      dateEn: rawDate,
      dateHijri: hijri['date'] ?? "",
      dayAr: weekday['ar'] ?? "",
      country: countryStr,
      region: regionStr,
    );
  }
}
