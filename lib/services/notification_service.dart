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

  Future<void> init() async {
    tz.initializeTimeZones();
    try {
      // محاولة تعيين التوقيت المحلي
      tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    } catch (e) {
      debugPrint("Could not set local location: $e");
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings =
        InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
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
    await _notificationsPlugin.cancel(id);
  }

  /// جدولة اليوم للصلاوات المخزنة بس
  Future<void> scheduleEnabledPrayers(PrayerTimes times) async {
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
      final DateTime scheduledTime =
          DateFormat("yyyy-MM-dd HH:mm").parse("$today $time");
      await schedulePrayerNotification(
        prayerIds[prayer]!,
        prayerNames[prayer]!,
        scheduledTime,
      );
    } catch (e) {
      debugPrint("Error scheduling $prayer: $e");
    }
  }

  Future<void> schedulePrayerNotification(
      int id, String title, DateTime scheduledTime) async {
    final now = DateTime.now();
    if (scheduledTime.isBefore(now)) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'مواقيت الصلاة',
      channelDescription: 'تنبيهات بمواعيد الصلوات الخمس',
      importance: Importance.max,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('azan'),
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      id,
      'موعد الصلاة',
      'حان الآن موعد $title',
      tz.TZDateTime.from(scheduledTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}

