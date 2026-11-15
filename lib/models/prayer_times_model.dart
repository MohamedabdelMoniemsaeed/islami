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

    String countryStr = (json['country'] ?? (data?['country'] ?? "")).toString().trim();
    String regionStr = (json['region'] ?? (data?['region'] ?? "")).toString().trim();

    // إذا جاءت الاستجابة من سيرفر الأذان بدون تحديد صريح للاسم، نستنتج الموقع من المنطقة الزمنية
    if (data != null && (countryStr.isEmpty || regionStr.isEmpty)) {
      final String tzName = (meta?['timezone'] ?? "").toString();
      String defaultRegion = "القاهرة";
      String defaultCountry = "مصر";

      if (tzName.contains("Riyadh") || tzName.contains("Makkah")) {
        defaultRegion = "مكة المكرمة";
        defaultCountry = "المملكة العربية السعودية";
      } else if (tzName.contains("Dubai")) {
        defaultRegion = "دبي";
        defaultCountry = "الإمارات";
      } else if (tzName.contains("Casablanca")) {
        defaultRegion = "الدار البيضاء";
        defaultCountry = "المغرب";
      } else if (tzName.contains("Jerusalem")) {
        defaultRegion = "القدس الشريف";
        defaultCountry = "فلسطين";
      }

      if (regionStr.isEmpty) regionStr = defaultRegion;
      if (countryStr.isEmpty) countryStr = defaultCountry;
    }

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
