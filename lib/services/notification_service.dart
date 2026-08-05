import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

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

  Future<void> scheduleAllPrayers(PrayerTimes times) async {
    final DateFormat formatter = DateFormat("yyyy-MM-dd");
    final String today = formatter.format(DateTime.now());

    await _schedule(0, "الفجر", "$today ${times.fajr}");
    await _schedule(1, "الظهر", "$today ${times.dhuhr}");
    await _schedule(2, "العصر", "$today ${times.asr}");
    await _schedule(3, "المغرب", "$today ${times.maghrib}");
    await _schedule(4, "العشاء", "$today ${times.isha}");
  }

  Future<void> _schedule(int id, String name, String timeStr) async {
    try {
      final DateTime scheduledTime =
          DateFormat("yyyy-MM-dd HH:mm").parse(timeStr);
      await schedulePrayerNotification(id, name, scheduledTime);
    } catch (e) {
      debugPrint("Error parsing time for $name: $e");
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

