import 'dart:async';
import 'package:flutter/material.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PrayerTimesTab extends StatefulWidget {
  const PrayerTimesTab({super.key});

  @override
  State<PrayerTimesTab> createState() => _PrayerTimesTabState();
}

class _PrayerTimesTabState extends State<PrayerTimesTab> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  // الـ Future اتولد مرة واحدة على مستوى الـ State (مش كل rebuild)
  late final Future<PrayerTimes> _times;

  // بيانات الأذان (محمّلة من SharedPreferences)
  bool _adhanMaster = true;
  String _adhanSound = NotificationService.defaultAdhanSound;

  // عدّاد تنازلي للصلاة القادمة
  Timer? _countdownTimer;
  PrayerTimes? _timesData;

  @override
  void initState() {
    super.initState();
    _times = _apiService.getPrayerTimes().then((times) {
      _notificationService.scheduleEnabledPrayers(times);
      if (mounted) setState(() => _timesData = times);
      return times;
    });
    _loadAdhanSettings();
    // تجديد كل ثانية عشان عدّاد "الوقت المتبقي" بيتحرك
    _countdownTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAdhanSettings() async {
    final master = await _notificationService.isMasterAdhanEnabled();
    final sound = await _notificationService.getAdhanSound();
    if (!mounted) return;
    setState(() {
      _adhanMaster = master;
      _adhanSound = sound;
    });
  }

  String _formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  /// الصلاة القادمة النهارده (أو فجر بكرة) + وقتها المتبقي
  ({String name, String time, DateTime target, bool isTomorrow})
      _nextPrayer(PrayerTimes times, DateTime now) {
    final prayers = [
      ("الفجر", times.fajr),
      ("الظهر", times.dhuhr),
      ("العصر", times.asr),
      ("المغرب", times.maghrib),
      ("العشاء", times.isha),
    ];
    for (final p in prayers) {
      // parse يرجع التاريخ ده بالوقت بتاع الصلاة
      final DateTime target = DateFormat("HH:mm").parse(p.$2);
      if (target.isAfter(now)) {
        return (name: p.$1, time: p.$2, target: target, isTomorrow: false);
      }
    }
    // الصلوات الخمس فاتت → فجر بكرة
    final DateTime fajrTomorrow =
        DateFormat("HH:mm").parse(times.fajr).add(const Duration(days: 1));
    return (name: "الفجر", time: times.fajr, target: fajrTomorrow, isTomorrow: true);
  }

  /// "01:23:45" (ساعة:دقيقة:ثانية)
  String _formatCountdown(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  Future<void> _onMasterAdhanToggle(bool value) async {
    setState(() => _adhanMaster = value);
    await _notificationService.setMasterAdhanEnabled(value);
    if (value) {
      await _reschedule("تم تفعيل الأذان");
    } else {
      await _notificationService.cancelAll();
      if (mounted) _showSnackBar("تم إيقاف الأذان");
    }
  }

  Future<void> _onAdhanSoundChanged(String? newSound) async {
    if (newSound == null || newSound == _adhanSound) return;
    setState(() => _adhanSound = newSound);
    await _notificationService.setAdhanSound(newSound);
    await _reschedule("تم تغيير صوت الأذان إلى ${NotificationService.adhanSoundLabel(newSound)}");
  }

  /// إعادة جدولة صلاوات اليوم (تقرأ الصوت الحالي فأي تغيير فيه بيتحسب)
  Future<void> _reschedule(String successMessage) async {
    try {
      final times = _timesData ?? await _apiService.getPrayerTimes();
      _timesData ??= times;
      await _notificationService.scheduleEnabledPrayers(times);
      if (mounted) _showSnackBar(successMessage);
    } catch (_) {
      if (mounted) _showSnackBar("تم الحفظ — الأذان بيتفعّل أول ما تكون بيانات المواقيت متاحة");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var locale = AppLocalizations.of(context)!;
    final isDark = provider.isDarkMode();

    return FutureBuilder<PrayerTimes>(
      future: _times,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "حدث خطأ في تحميل البيانات",
              style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 18),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final times = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
          child: ListView(
            children: [
              Text(
                locale.prayerTimes,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.yellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              Text(
                "${times.dayAr} - ${times.dateHijri} هـ",
                style: const TextStyle(color: AppColors.yellow, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                times.dateEn,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: AppColors.yellow, size: 18),
                  Text(
                    " ${times.region}, ${times.country}",
                    style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              // ===== الصلاة القادمة + الوقت المتبقي =====
              _buildNextPrayerCard(context, times, isDark),
              const SizedBox(height: 15),
              // ===== المواقيت =====
              for (final item in [
                    ("الفجر", times.fajr),
                    ("الشروق", times.sunrise),
                    ("الظهر", times.dhuhr),
                    ("العصر", times.asr),
                    ("المغرب", times.maghrib),
                    ("العشاء", times.isha),
                  ])
                _buildPrayerItem(context, item.$1, _formatTime(item.$2), isDark),
              const SizedBox(height: 15),
              // ===== الأذان =====
              _buildAdhanCard(context, isDark),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  /// بطاقة "الصلاة القادمة" مع عدّاد تنازلي حيّ
  Widget _buildNextPrayerCard(
      BuildContext context, PrayerTimes times, bool isDark) {
    final now = DateTime.now();
    final next = _nextPrayer(times, now);
    final remaining = next.target.difference(now);
    final remainingText =
        remaining.isNegative ? "—" : _formatCountdown(remaining);
    final timeParts = _formatTime(next.time).split(' ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.yellowDark.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                next.isTomorrow
                    ? "الصلاة القادمة (غداً)"
                    : "الصلاة القادمة",
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              Text(
                next.name,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellow,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeParts.first,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    timeParts.last,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                ],
              ),
              // الوقت المتبقي (ساعة:دقيقة:ثانية) بيتجدد كل ثانية
              Text(
                "المتبقي: $remainingText",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: isDark ? AppColors.blackDark : Colors.black87,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// قسم الأذان: تفعيل رئيسي + اختيار صوت المؤذن
  Widget _buildAdhanCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.yellowDark.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "أذان الصلاة",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.yellow,
                ),
              ),
              Switch(
                value: _adhanMaster,
                onChanged: _onMasterAdhanToggle,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "صوت المؤذن",
                style: TextStyle(
                  fontSize: 18,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              DropdownButton<String>(
                value: _adhanSound,
                dropdownColor:
                    isDark ? AppColors.yellowDark : Colors.white,
                underline: const SizedBox.shrink(),
                borderRadius: BorderRadius.circular(10),
                items: [
                  for (final s in NotificationService.adhanSounds)
                    DropdownMenuItem(
                      value: s.$1,
                      child: Text(
                        s.$2,
                        style: TextStyle(
                          fontSize: 15,
                          color: s.$1 == _adhanSound
                              ? (isDark ? AppColors.blackDark : AppColors.yellow)
                              : Colors.grey,
                          fontWeight: s.$1 == _adhanSound
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                ],
                onChanged: _adhanMaster ? _onAdhanSoundChanged : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerItem(BuildContext context, String name, String time, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.yellowDark.withValues(alpha: 0.7)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.yellow,
            ),
          ),
          Row(
            children: [
              Text(
                time.split(' ').first, // الجزء الخاص بالأرقام (مثلاً 05:30)
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                time.split(' ').last, // الجزء الخاص بـ AM/PM
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
