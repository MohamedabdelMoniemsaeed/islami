import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final List<MethodCall> log = <MethodCall>[];

  setUp(() {
    log.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      log.add(methodCall);
      if (methodCall.method == 'initialize') return true;
      if (methodCall.method == 'zonedSchedule') return true;
      if (methodCall.method == 'cancel') return true;
      if (methodCall.method == 'cancelAll') return true;
      return null;
    });
  });

  group('NotificationService Scheduling & Timezone Tests', () {
    test('initializes and configures channel version', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();
      await service.init();
      expect(NotificationService.channelVersion, 'prayer_adhan_v5');
      expect(log.any((m) => m.method == 'initialize'), isTrue);
    });

    test('schedulePrayerNotification handles past and future dates', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();

      // جدولة وقت سابق (يجب نقله تلقائياً إلى الغد)
      final past = DateTime.now().subtract(const Duration(hours: 2));
      await service.schedulePrayerNotification(1, 'الظهر', past);

      // جدولة وقت قادم
      final future = DateTime.now().add(const Duration(hours: 2));
      await service.schedulePrayerNotification(2, 'العصر', future);

      final schedules = log.where((m) => m.method == 'zonedSchedule').toList();
      expect(schedules.length, 2);
    });

    test('scheduleEnabledPrayers schedules all 5 prayers when enabled', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();
      final times = PrayerTimes(
        fajr: '05:00',
        sunrise: '06:20',
        dhuhr: '12:30',
        asr: '15:45',
        maghrib: '18:10',
        isha: '19:30',
        dateEn: '2026-11-15',
        dateHijri: '1448-05-05',
        dayAr: 'الأحد',
        country: 'Egypt',
        region: 'Cairo',
      );

      await service.scheduleEnabledPrayers(times);
      final schedules = log.where((m) => m.method == 'zonedSchedule').toList();
      expect(schedules.length, 5);
    });
  });
}
