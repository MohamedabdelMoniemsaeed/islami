import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// يحفظ سلوك الـ guards بدون أي لمس لكانال FlutterLocalNotifications:
// التخطي للأزمنة الماضية والـ no-op بيعدوا قبل أي استدعاء للكانال.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  PrayerTimes pastTimes() => PrayerTimes(
        fajr: '00:00',
        sunrise: '00:00',
        dhuhr: '00:00',
        asr: '00:00',
        maghrib: '00:00',
        isha: '00:00',
        dateEn: '',
        dateHijri: '',
        dayAr: '',
        country: '',
        region: '',
      );

  group('NotificationService guards', () {
    test('all prayers are enabled by default when prefs are empty', () async {
      SharedPreferences.setMockInitialValues({});
      final enabled = await NotificationService().getEnabledPrayers();
      expect(enabled, {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'});
    });

    test('setPrayerEnabled(false) is persisted and respected', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();
      await service.setPrayerEnabled('isha', false);
      expect(await service.getEnabledPrayers(), isNot(contains('isha')));
      await service.setPrayerEnabled('isha', true);
      expect(await service.getEnabledPrayers(), contains('isha'));
    });

    test('a stored adhan_<prayer>=false is honored on read', () async {
      SharedPreferences.setMockInitialValues({
        '${NotificationService.adhanKeyPrefix}fajr': false,
      });
      expect(
        await NotificationService().getEnabledPrayers(),
        isNot(contains('fajr')),
      );
    });

    test('past-time scheduling is skipped without touching the plugin channel',
        () async {
      SharedPreferences.setMockInitialValues({});
      await NotificationService().schedulePrayerNotification(
        0,
        'الفجر',
        DateTime.now().subtract(const Duration(hours: 1)),
      );
    });

    test('scheduleEnabledPrayers with past times completes hermetically',
        () async {
      SharedPreferences.setMockInitialValues({});
      await NotificationService().scheduleEnabledPrayers(pastTimes());
    });

    test('cancelling an unknown prayer is a no-op', () async {
      SharedPreferences.setMockInitialValues({});
      await NotificationService().cancelPrayerNotification('midhat');
    });
  });
}
