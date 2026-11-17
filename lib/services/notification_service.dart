import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // إعدادات الأذان: مفتاح prefs لكل صلاة + id ثابت لكل إشعار
  static const Map<String, int> prayerIds = {
    'fajr': 0,
    'dhuhr': 1,
    'asr': 2,
    'maghrib': 3,
    'isha': 4,
  };
  static const Map<String, String> prayerNames = {
    'fajr': 'الفجر',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };
  static const String adhanKeyPrefix = 'adhan_';
  static const String adhanMasterKey = 'adhan_master';
  static const String adhanSoundKey = 'adhan_sound';

  /// أصوات الأذان المتاحة: (اسم الـ resource في res/raw، التسمية المعروضة)
  static const List<(String, String)> adhanSounds = [
    ('adhan_1', 'المؤذن ١'),
    ('adhan_2', 'المؤذن ٢'),
    ('adhan_3', 'المؤذن ٣'),
    ('adhan_4', 'المؤذن ٤'),
  ];
  static const String defaultAdhanSound = 'adhan_1';

  static const String channelVersion = 'prayer_adhan_v5';

  /// اسم الـ raw resource للصوت المختار
  Future<String> getAdhanSound() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(adhanSoundKey);
    if (stored != null && ['adhan_1', 'adhan_2', 'adhan_3', 'adhan_4'].contains(stored)) {
      return stored;
    }
    return defaultAdhanSound;
  }

  static Future<List<(String, String)>> availableAdhanSounds() async {
    return adhanSounds;
  }

  Future<void> setAdhanSound(String soundId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(adhanSoundKey, soundId);
  }

  static String adhanSoundLabel(String soundId) {
    switch (soundId) {
      case 'adhan_2':
        return 'المؤذن ٢';
      case 'adhan_3':
        return 'المؤذن ٣';
      case 'adhan_4':
        return 'المؤذن ٤';
      case 'adhan_1':
      default:
        return 'المؤذن ١';
    }
  }

  static void _ensureTimeZonesInitialized() {
    try {
      tz.local;
    } catch (_) {
      tz.initializeTimeZones();
      try {
        final offsetMillis = DateTime.now().timeZoneOffset.inMilliseconds;
        final matchingLoc = tz.timeZoneDatabase.locations.values.firstWhere(
          (loc) => loc.currentTimeZone.offset == offsetMillis,
          orElse: () => tz.getLocation('Africa/Cairo'),
        );
        tz.setLocalLocation(matchingLoc);
      } catch (_) {}
    }
  }

  Future<void> init() async {
    _ensureTimeZonesInitialized();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    // طلب صلاحيات الإشعارات والتنبيهات الدقيقة لنظام أندرويد 13 فما فوق
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    try {
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
    } catch (e) {
      debugPrint("Notification permissions request error: $e");
    }

    // تنظيف القنوات القديمة والمؤقتة لضمان اعتماد إعدادات الصوت والإنذار الجديدة
    try {
      final legacyChannels = [
        'prayer_channel',
        'prayer_notifications',
        'prayer_channel_adhan_1',
        'prayer_channel_adhan_2',
        'prayer_channel_adhan_3',
        'prayer_channel_adhan_4',
        'prayer_adhan_v4_adhan_1',
        'prayer_adhan_v4_adhan_2',
        'prayer_adhan_v4_adhan_3',
        'prayer_adhan_v4_adhan_4',
      ];
      for (final ch in legacyChannels) {
        await androidPlugin?.deleteNotificationChannel(ch);
      }
    } catch (_) {}
  }

  /// الزر الرئيسي للأذان (ملحق افتراضيًا)
  Future<bool> isMasterAdhanEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(adhanMasterKey) ?? true;
  }

  Future<void> setMasterAdhanEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(adhanMasterKey, enabled);
  }

  /// حالة كل صلاة محفوظة (سواء الرئيسي شغال أو لا) — للعرض في صفحة الإعدادات
  Future<Map<String, bool>> getPrayerStates() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final p in prayerIds.keys)
        p: prefs.getBool('$adhanKeyPrefix$p') ?? true,
    };
  }

  /// الصلوات المشغّلة فعلاً (الرئيسي شغال والصلاة نفسها مش معطّلة)
  Future<Set<String>> getEnabledPrayers() async {
    if (!(await isMasterAdhanEnabled())) return {};
    final prefs = await SharedPreferences.getInstance();
    return prayerIds.keys
        .where((p) => prefs.getBool('$adhanKeyPrefix$p') ?? true)
        .toSet();
  }

  /// تفعيل/إيقاف أذان صلاة معينة (بيتحفظ)
  Future<void> setPrayerEnabled(String prayer, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$adhanKeyPrefix$prayer', enabled);
  }

  /// إلغاء إشعار صلاة معينة (لو مفيش جدولة، الغاها مرفوضة ومفيش تأثير)
  Future<void> cancelPrayerNotification(String prayer) async {
    final id = prayerIds[prayer];
    if (id == null) return;
    try {
      await _notificationsPlugin.cancel(id);
    } catch (_) {}
  }

  /// جدولة الصلوات المشغلة: يلغي الجداول السابقة ويعيد جدولة كل صلاة مفعّلة
  Future<void> scheduleEnabledPrayers(PrayerTimes times) async {
    await cancelAll();
    final enabled = await getEnabledPrayers();
    final timesByPrayer = {
      'fajr': times.fajr,
      'dhuhr': times.dhuhr,
      'asr': times.asr,
      'maghrib': times.maghrib,
      'isha': times.isha,
    };
    for (final prayer in prayerIds.keys) {
      if (!enabled.contains(prayer)) continue;
      await _schedule(prayer, timesByPrayer[prayer]!);
    }
  }

  Future<void> _schedule(String prayer, String time) async {
    try {
      final today = DateFormat("yyyy-MM-dd").format(DateTime.now());
      final DateTime? scheduledTime = _parsePrayerDateTime(today, time);
      if (scheduledTime != null) {
        await schedulePrayerNotification(
          prayerIds[prayer]!,
          prayerNames[prayer]!,
          scheduledTime,
        );
      }
    } catch (e) {
      debugPrint("Error scheduling $prayer: $e");
    }
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
          int year, month, day;
          if (parts[0].length == 4) {
            year = int.parse(parts[0]);
            month = int.parse(parts[1]);
            day = int.parse(parts[2]);
          } else {
            day = int.parse(parts[0]);
            month = int.parse(parts[1]);
            year = int.parse(parts[2]);
          }
          return DateTime(year, month, day, hour, minute);
        } catch (_) {}
      }
    }
    return null;
  }

  Future<void> schedulePrayerNotification(
      int id, String title, DateTime scheduledTime) async {
    _ensureTimeZonesInitialized();
    final now = DateTime.now();
    // إذا كان وقت الصلاة لليوم قد مر، تُجدول لنفس الوقت غداً
    DateTime targetTime = scheduledTime;
    if (targetTime.isBefore(now)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }

    final soundId = await getAdhanSound();
    final soundLabel = adhanSoundLabel(soundId);
    // تخصيص معرف القناة لكل صوت أذان ليحترم أندرويد 8+ تغيير الصوت ويمنع التخزين المؤقت
    final channelId = '${channelVersion}_$soundId';

    try {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      final channel = AndroidNotificationChannel(
        channelId,
        'أذان $soundLabel',
        description: 'تنبيهات بمواعيد الصلوات الخمس مع صوت الأذان',
        importance: Importance.max,
        playSound: true,
        sound: RawResourceAndroidNotificationSound(soundId),
        enableVibration: true,
        enableLights: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      );
      await androidPlugin?.createNotificationChannel(channel);
    } catch (_) {}

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      'أذان $soundLabel',
      channelDescription: 'تنبيهات بمواعيد الصلوات الخمس مع صوت الأذان',
      importance: Importance.max,
      priority: Priority.max,
      playSound: true,
      enableVibration: true,
      sound: RawResourceAndroidNotificationSound(soundId),
      audioAttributesUsage: AudioAttributesUsage.alarm,
      category: AndroidNotificationCategory.alarm,
      fullScreenIntent: false,
      visibility: NotificationVisibility.public,
      ticker: 'حان الآن موعد أذان $title',
      styleInformation: BigTextStyleInformation(
        'حان الآن موعد أذان صلاة $title، حي على الصلاة، حي على الفلاح',
        contentTitle: 'موعد الصلاة',
        summaryText: 'أذان $title',
      ),
    );

    final NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    // بناء توقيت محلي جداري دقيق
    final scheduledDate = tz.TZDateTime(
      tz.local,
      targetTime.year,
      targetTime.month,
      targetTime.day,
      targetTime.hour,
      targetTime.minute,
    );

    // 1. المحاولة الأولى بـ exactAllowWhileIdle مع التكرار اليومي (أكثر استقراراً في الخلفية وعند إغلاق التطبيق)
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'موعد أذان $title',
        'حان الآن موعد أذان صلاة $title',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    } catch (e) {
      debugPrint("exactAllowWhileIdle schedule failed for $title: $e, falling back to alarmClock");
    }

    // 2. المحاولة البديلة بـ alarmClock
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'موعد أذان $title',
        'حان الآن موعد أذان صلاة $title',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      return;
    } catch (e) {
      debugPrint("alarmClock schedule failed for $title: $e, falling back to inexact");
    }

    // 3. المحاولة البديلة بـ inexact (تضمن وصول الإشعار حتى بدون صلاحية المنبه الدقيق)
    try {
      await _notificationsPlugin.zonedSchedule(
        id,
        'موعد أذان $title',
        'حان الآن موعد أذان صلاة $title',
        scheduledDate,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("inexact schedule failed for $title: $e");
    }
  }

  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}

