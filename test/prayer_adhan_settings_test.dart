import 'package:flutter_test/flutter_test.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('adhan settings persistence', () {
    test('all prayers enabled by default', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();
      expect(await service.isMasterAdhanEnabled(), isTrue);
      expect(
        await service.getEnabledPrayers(),
        {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'},
      );
    });

    test('a disabled prayer is excluded but others stay on', () async {
      SharedPreferences.setMockInitialValues({'adhan_fajr': false});
      final enabled = await NotificationService().getEnabledPrayers();
      expect(enabled.contains('fajr'), isFalse);
      expect(enabled.contains('dhuhr'), isTrue);
    });

    test('master off disables every prayer', () async {
      SharedPreferences.setMockInitialValues({'adhan_master': false});
      expect(await NotificationService().getEnabledPrayers(), isEmpty);
      // الحالة الفردية لكل صلاة لسه محفوظة (تعرض في صفحة الإعدادات)
      final states = await NotificationService().getPrayerStates();
      expect(states, {
        'fajr': true,
        'dhuhr': true,
        'asr': true,
        'maghrib': true,
        'isha': true,
      });
    });

    test('toggle round-trip', () async {
      SharedPreferences.setMockInitialValues({});
      final service = NotificationService();
      await service.setPrayerEnabled('isha', false);
      expect((await service.getPrayerStates())['isha'], isFalse);
      await service.setMasterAdhanEnabled(false);
      expect(await service.getEnabledPrayers(), isEmpty);
      await service.setMasterAdhanEnabled(true);
      expect((await service.getEnabledPrayers()).contains('isha'), isFalse);
    });

    test('prayer ids are unique', () {
      final ids = NotificationService.prayerIds.values.toSet();
      expect(ids.length, NotificationService.prayerIds.length);
    });
  });

  group('PrayerTimes.fromJson robustness', () {
    test('tolerates missing sub-objects', () {
      final times = PrayerTimes.fromJson({
        'prayer_times': {'Fajr': '04:41'},
        'date': {},
      });
      expect(times.fajr, '04:41');
      expect(times.dhuhr, '');
      expect(times.dayAr, '');
    });

    test('tolerates an empty payload', () {
      final times = PrayerTimes.fromJson({});
      expect(times.fajr, '');
      expect(times.region, '');
    });
  });
}
