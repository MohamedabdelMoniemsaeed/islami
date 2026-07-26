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
  bool _notificationsScheduled = false;

  String _formatTime(String time) {
    try {
      final DateTime parsedTime = DateFormat("HH:mm").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return time;
    }
  }

  void _scheduleNotifications(PrayerTimes times) {
    if (_notificationsScheduled) return;
    
    final DateFormat formatter = DateFormat("yyyy-MM-dd");
    final String today = formatter.format(DateTime.now());

    _schedule(0, "الفجر", "$today ${times.fajr}");
    _schedule(1, "الظهر", "$today ${times.dhuhr}");
    _schedule(2, "العصر", "$today ${times.asr}");
    _schedule(3, "المغرب", "$today ${times.maghrib}");
    _schedule(4, "العشاء", "$today ${times.isha}");

    _notificationsScheduled = true;
  }

  void _schedule(int id, String name, String timeStr) {
    try {
      final DateTime scheduledTime = DateFormat("yyyy-MM-dd HH:mm").parse(timeStr);
      _notificationService.schedulePrayerNotification(id, name, scheduledTime);
    } catch (e) {
      debugPrint("Error scheduling notification for $name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var locale = AppLocalizations.of(context)!;

    return FutureBuilder<PrayerTimes>(
      future: _apiService.getPrayerTimes("Cairo", "Egypt"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "حدث خطأ في تحميل البيانات",
              style: TextStyle(color: provider.isDarkMode() ? Colors.white : Colors.black, fontSize: 18),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final times = snapshot.data!;
        // جدولة الإشعارات بمجرد تحميل البيانات
        _scheduleNotifications(times);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30),
          child: Column(
            children: [
              Text(
                locale.prayerTimes,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.yellow,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                times.date,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPrayerItem(context, "الفجر", _formatTime(times.fajr), provider.isDarkMode()),
                    _buildPrayerItem(context, "الظهر", _formatTime(times.dhuhr), provider.isDarkMode()),
                    _buildPrayerItem(context, "العصر", _formatTime(times.asr), provider.isDarkMode()),
                    _buildPrayerItem(context, "المغرب", _formatTime(times.maghrib), provider.isDarkMode()),
                    _buildPrayerItem(context, "العشاء", _formatTime(times.isha), provider.isDarkMode()),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerItem(BuildContext context, String name, String time, bool isDark) {
    return Expanded(
      child: Container(
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
              time,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            Text(
              name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.yellow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
