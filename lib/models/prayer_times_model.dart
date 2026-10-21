class PrayerTimes {
  final String fajr;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String date;

  PrayerTimes({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.date,
  });

  factory PrayerTimes.fromJson(Map<String, dynamic> json) {
    final timings = json['timings'] ?? json;
    return PrayerTimes(
      fajr: timings['Fajr'] ?? '05:00',
      dhuhr: timings['Dhuhr'] ?? '12:00',
      asr: timings['Asr'] ?? '15:30',
      maghrib: timings['Maghrib'] ?? '18:00',
      isha: timings['Isha'] ?? '19:30',
      date: json['date']?['readable'] ?? DateTime.now().toString(),
    );
  }
}
