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
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';

class PrayerTimesTab extends StatefulWidget {
  const PrayerTimesTab({super.key});

  @override
  State<PrayerTimesTab> createState() => _PrayerTimesTabState();
}

class _PrayerTimesTabState extends State<PrayerTimesTab> {
  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();

  late final Future<PrayerTimes> _times;

  bool _adhanMaster = true;
  Set<String>? _adhanPrayers;
  String _adhanSound = NotificationService.defaultAdhanSound;
  // عرض أصوات المؤذنين الأربعة فقط
  static const List<(String, String)> _adhanPreviewSounds = [
    ('adhan_1', 'المؤذن ١'),
    ('adhan_2', 'المؤذن ٢'),
    ('adhan_3', 'المؤذن ٣'),
    ('adhan_4', 'المؤذن ٤'),
  ];

  Timer? _countdownTimer;
  PrayerTimes? _timesData;

  // حالة العد التنازلي (تُحدث كل ثانية)
  ({String name, String time, DateTime target, bool isTomorrow, String remaining})
      _countdownInfo =
      (name: '', time: '', target: DateTime.now(), isTomorrow: false, remaining: '');
  double _progress = 0.0;

  // مشغل الصوت للمعاينة
  final AudioPlayer _previewPlayer = AudioPlayer();
  int? _playingPreviewId; // sound index being played

  @override
  void initState() {
    super.initState();
    _times = _apiService.getPrayerTimes().then((times) {
      _notificationService.scheduleEnabledPrayers(times);
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false)
            .updateCachedPrayerTimes(times);
        setState(() => _timesData = times);
      }
      return times;
    });
    _loadAdhanSettings();
    _initAudioSession();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
      if (mounted) setState(() {});
    });

    // استماع لحالة مشغل المعاينة لتحديث الأيقونة
    _previewPlayer.playerStateStream.listen((state) {
      if (mounted) {
        if (!state.playing || state.processingState == ProcessingState.completed) {
          setState(() => _playingPreviewId = null);
        } else {
          // جلب المعرف من الـ tag الحالي
          final currentTag = _previewPlayer.sequenceState?.currentSource?.tag;
          if (currentTag is MediaItem) {
            final idx = _adhanPreviewSounds.indexWhere((s) => s.$1 == currentTag.id);
            if (idx != -1) {
              setState(() => _playingPreviewId = idx);
            }
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _previewPlayer.dispose();
    super.dispose();
  }

  /// تحديث العد التنازلي للصلاة القادمة كل ثانية
  void _updateCountdown() {
    final times = _timesData;
    if (times == null) return;
    final now = DateTime.now();
    final result = _nextPrayer(times, now);
    final remaining = result.target.difference(now);
    final remainingText =
        remaining.isNegative ? "—" : _formatCountdown(remaining);
    // شريط التقدم: نسبة الوقت المنقضي من 24 ساعة حتى الصلاة القادمة
    final double totalSec =
        (remaining.inSeconds > 0) ? remaining.inSeconds.toDouble() : 86400.0;
    final double prog =
        ((totalSec - remaining.inSeconds.toDouble()).clamp(0.0, totalSec)) /
            totalSec;
    if (mounted) {
      setState(() {
        _countdownInfo = (
          name: result.name,
          time: result.time,
          target: result.target,
          isTomorrow: result.isTomorrow,
          remaining: remainingText,
        );
        _progress = prog;
      });

      // تشغيل فحص الأذان التلقائي فور وصول العداد للصفر
      if (remaining.inSeconds >= -5 && remaining.inSeconds <= 2) {
        Provider.of<AppProvider>(context, listen: false)
            .checkPrayerTimesAndTriggerNow();
      }
    }
  }

  Future<void> _initAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
  }

  Future<void> _loadAdhanSettings() async {
    final master = await _notificationService.isMasterAdhanEnabled();
    final sound = await _notificationService.getAdhanSound();
    final states = await _notificationService.getPrayerStates();
    if (!mounted) return;
    setState(() {
      _adhanMaster = master;
      _adhanSound = sound;
      _adhanPrayers =
          states.entries.where((e) => e.value).map((e) => e.key).toSet();
    });
  }

  String _formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat("HH:mm").parse(time);
      // تنسيق الوقت بالعربية (ص/م)
      return DateFormat("hh:mm a", "ar").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  ({String name, String time, DateTime target, bool isTomorrow}) _nextPrayer(
      PrayerTimes times, DateTime now) {
    final prayers = [
      ("الفجر", times.fajr),
      ("الظهر", times.dhuhr),
      ("العصر", times.asr),
      ("المغرب", times.maghrib),
      ("العشاء", times.isha),
    ];
    final todayStr = DateFormat("yyyy-MM-dd").format(now);
    final today = DateTime(now.year, now.month, now.day);

    for (final p in prayers) {
      final target = _parsePrayerDateTime(todayStr, p.$2);
      if (target != null && !target.isBefore(now)) {
        return (name: p.$1, time: p.$2, target: target, isTomorrow: false);
      }
    }
    // كل صلوات اليوم انتهت → الفجر غداً
    final fajrTomorrow = (_parsePrayerDateTime(todayStr, times.fajr) ?? today)
        .add(const Duration(days: 1));
    return (name: "الفجر", time: times.fajr, target: fajrTomorrow,
        isTomorrow: true);
  }

  DateTime? _parsePrayerDateTime(String dateStr, String timeStr) {
    if (timeStr.isEmpty) return null;
    final cleanTime = timeStr.replaceAll(RegExp(r'\s*\([A-Za-z\s]+\)\s*'), '').trim();
    final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(cleanTime);
    if (match != null) {
      final hour = int.parse(match.group(1)!);
      final minute = int.parse(match.group(2)!);
      final parts = dateStr.split('-');
      if (parts.length == 3) {
        try {
          return DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
            hour,
            minute,
          );
        } catch (_) {}
      }
    }
    return null;
  }

  String _formatCountdown(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inHours)}:${two(d.inMinutes % 60)}:${two(d.inSeconds % 60)}";
  }

  // ===== معاينة صوت الأذان =====
  Future<void> _playPreview(int index, String soundId) async {
    if (_playingPreviewId == index) {
      await _previewPlayer.stop();
      return;
    }

    try {
      await _previewPlayer.stop();
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // حل مشكلة 'Null' is not a subtype of 'MediaItem' بإضافة tag
      // نقوم بتعريف MediaItem لكل صوت ليتوافق مع just_audio_background
      await _previewPlayer.setAsset(
        'assets/sounds/${index + 1}.mp3',
        tag: MediaItem(
          id: soundId,
          album: 'أذان',
          title: _adhanPreviewSounds[index].$2,
          artist: 'تطبيق إسلامي',
        ),
      );

      await _previewPlayer.play();
    } catch (e) {
      debugPrint("Preview play error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("تعذر تشغيل المعاينة: $e")),
        );
      }
    }
  }

  // ===== إعدادات الأذان =====
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

  Future<void> _onPrayerToggle(String prayer, String name, bool value) async {
    final states = Set<String>.from(_adhanPrayers ?? {});
    if (value) {
      states.add(prayer);
    } else {
      states.remove(prayer);
    }
    setState(() => _adhanPrayers = states);
    await _notificationService.setPrayerEnabled(prayer, value);
    if (value) {
      await _reschedule("تم تفعيل أذان $name");
    } else {
      await _notificationService.cancelPrayerNotification(prayer);
      if (mounted) _showSnackBar("تم إيقاف أذان $name");
    }
  }

  Future<void> _onAdhanSoundChanged(String? newSound) async {
    if (newSound == null || newSound == _adhanSound) return;
    setState(() => _adhanSound = newSound);
    await _notificationService.setAdhanSound(newSound);
    await _reschedule(
        "تم تغيير صوت الأذان إلى ${NotificationService.adhanSoundLabel(newSound)}");
  }

  Future<void> _reschedule(String successMessage) async {
    try {
      final times = _timesData ?? await _apiService.getPrayerTimes();
      _timesData ??= times;
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false)
            .updateCachedPrayerTimes(times);
      }
      await _notificationService.scheduleEnabledPrayers(times);
      if (mounted) _showSnackBar(successMessage);
    } catch (_) {
      if (mounted) {
        _showSnackBar("تم الحفظ — الأذان بيتفعّل أول ما تكون بيانات المواقيت متاحة");
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.yellow));
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
          return const Center(
              child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "حدث خطأ في تحميل البيانات",
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black, fontSize: 18),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final times = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // ===== العنوان + التاريخ =====
            _buildHeader(locale, times, isDark),
            const SizedBox(height: 16),

            // ===== بطاقة الصلاة القادمة (Hero) — تستخدم القيم المحدثة في كل ثانية =====
            _buildNextPrayerHero(
                context, _countdownInfo, _progress, isDark),
            const SizedBox(height: 16),

            // ===== قائمة الصلوات =====
            ...[
              ("الفجر", times.fajr, 'fajr', Icons.nights_stay),
              ("الشروق", times.sunrise, 'sunrise', Icons.wb_sunny),
              ("الظهر", times.dhuhr, 'dhuhr', Icons.wb_sunny_rounded),
              ("العصر", times.asr, 'asr', Icons.nature_people),
              ("المغرب", times.maghrib, 'maghrib', Icons.nightlight),
              ("العشاء", times.isha, 'isha', Icons.star_rounded),
            ].map((item) {
              final isNext = item.$1 == _countdownInfo.name;
              return _buildPrayerRow(
                  context, item.$1, _formatTime(item.$2), item.$3,
                  remainingText: isNext ? _countdownInfo.remaining : null,
                  isNext: isNext, isDark: isDark);
            }),
            const SizedBox(height: 16),

            // ===== بطاقة إعدادات الأذان =====
            _buildAdhanCard(context, isDark),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations locale, PrayerTimes times, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 0),
        Text(
          "${times.dayAr} - ${times.dateHijri} هـ",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? Colors.white70 : Colors.black54,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_on, size: 14, color: AppColors.yellow),
            const SizedBox(width: 4),
            Text(
              "${times.region}، ${times.country}",
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// بطاقة الصلاة القادمة بتصميم Hero متدرج
  Widget _buildNextPrayerHero(
      BuildContext context,
      ({String name, String time, DateTime target, bool isTomorrow, String remaining}) info,
      double progress,
      bool isDark) {
    final color = isDark
        ? const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xff1a2332), AppColors.yellowDark],
          )
        : const LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [AppColors.yellow, Color(0xffd4a84b)],
          );

    // شريط التقدم: 0 = الصلاة القادمة بعد وقت طويل, 1 = قريبة
    return Container(
      decoration: BoxDecoration(
        gradient: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // شريط التقدم
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark
                    ? Colors.white24
                    : Colors.white.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.yellowDark : Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // الجانب الأيمن: اسم الصلاة والوقت
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.isTomorrow
                            ? "الصلاة القادمة (غداً)"
                            : "الصلاة القادمة",
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? Colors.white70
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            info.name == "الفجر"
                                ? Icons.nights_stay
                                : info.name == "الشروق"
                                    ? Icons.wb_sunny
                                    : info.name == "الظهر"
                                        ? Icons.wb_sunny_rounded
                                        : info.name == "العصر"
                                            ? Icons.nature_people
                                            : info.name == "المغرب"
                                                ? Icons.nightlight
                                                : Icons.star_rounded,
                            size: 22,
                            color: isDark ? AppColors.yellowDark : Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            info.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // الجانب الأيسر: الوقت والعداد
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatTime(info.time),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            info.remaining,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              fontFeatures:
                                  [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// صف واحد لكل صلاة: أيقونة + الاسم + الوقت + زر الأذان
  Widget _buildPrayerRow(BuildContext context, String name, String time,
      String prayerKey,
      {String? remainingText, bool isNext = false, required bool isDark}) {
    final IconData icon;
    switch (name) {
      case 'الفجر':
        icon = Icons.nights_stay;
        break;
      case 'الشروق':
        icon = Icons.wb_sunny;
        break;
      case 'الظهر':
        icon = Icons.wb_sunny_rounded;
        break;
      case 'العصر':
        icon = Icons.nature_people;
        break;
      case 'المغرب':
        icon = Icons.nightlight;
        break;
      default:
        icon = Icons.star_rounded;
    }

    final bool isEnabled =
        _adhanMaster && (_adhanPrayers?.contains(prayerKey) ?? true);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark
            ? (isNext
                ? AppColors.yellowDark.withValues(alpha: 0.9)
                : Colors.white.withValues(alpha: 0.06))
            : (isNext
                ? AppColors.yellow.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.85)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isNext
              ? AppColors.yellow
              : (isDark ? Colors.white12 : Colors.black12),
          width: isNext ? 2 : 1,
        ),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.yellow
                : (isDark ? AppColors.yellowDark : Colors.grey.shade200),
            shape: BoxShape.circle,
          ),
          child: Icon(icon,
              color: isNext
                  ? (isDark ? AppColors.yellowDark : Colors.white)
                  : AppColors.yellow,
              size: 24),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: remainingText != null
            ? Text(
                "المتبقي: $remainingText",
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.yellowDark : AppColors.yellow,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عرض الوقت
            Text(
              time,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 12),
            // زر الأذان
            Switch(
              value: isEnabled,
              onChanged: _adhanMaster
                  ? (v) => _onPrayerToggle(prayerKey, name, v)
                  : null,
              activeThumbColor: AppColors.yellow,
            ),
          ],
        ),
      ),
    );
  }

  /// بطاقة إعدادات الأذان — تعرض 4 أصوات المؤذنين مع زر معاينة
  Widget _buildAdhanCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الرأس: العنوان + المفتاح الرئيسي
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.notifications_active,
                      color: AppColors.yellow, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    "إعدادات الأذان",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.yellow),
                  ),
                ],
              ),
              Switch(
                value: _adhanMaster,
                onChanged: _onMasterAdhanToggle,
                activeThumbColor: AppColors.yellow,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // اختيار صوت المؤذن + معاينة
          ..._adhanPreviewSounds.map((sound) {
            final idx = _adhanPreviewSounds.indexOf(sound);
            final isSelected = sound.$1 == _adhanSound;
            final isPlaying = _playingPreviewId == idx;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  // خيار الاختيار
                  Expanded(
                    child: Row(
                      children: [
                        Radio<String>(
                          value: sound.$1,
                          groupValue: _adhanSound,
                          onChanged: _adhanMaster
                              ? (v) => _onAdhanSoundChanged(v)
                              : null,
                          activeColor: AppColors.yellow,
                        ),
                        Expanded(
                          child: Text(
                            sound.$2,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isSelected ? FontWeight.bold : null,
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.yellowDark
                                      : AppColors.yellow)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // زر المعاينة (▶ / ⏸)
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: isSelected
                          ? AppColors.yellow
                          : (isDark ? Colors.white54 : Colors.black45),
                      size: 32,
                    ),
                    onPressed: _adhanMaster
                        ? () => _playPreview(idx, sound.$1)
                        : null,
                    tooltip: isPlaying ? "إيقاف" : "معاينة",
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
