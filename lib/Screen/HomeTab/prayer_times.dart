import 'package:flutter/material.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class PrayerTimesTab extends StatelessWidget {
  const PrayerTimesTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final ApiService apiService = ApiService();
    var locale = AppLocalizations.of(context)!;

    return FutureBuilder<PrayerTimes>(
      future: apiService.getPrayerTimes("Cairo", "Egypt"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "حدث خطأ في تحميل البيانات",
              style: TextStyle(color: provider.isDarkMode() ? Colors.white : Colors.black),
            ),
          );
        } else if (!snapshot.hasData) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final times = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(
                locale.prayerTimes,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.yellow,
                  fontSize: 28,
                ),
              ),
              Text(
                times.date,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView(
                  children: [
                    _buildPrayerItem(context, "الفجر", times.fajr, provider.isDarkMode()),
                    _buildPrayerItem(context, "الظهر", times.dhuhr, provider.isDarkMode()),
                    _buildPrayerItem(context, "العصر", times.asr, provider.isDarkMode()),
                    _buildPrayerItem(context, "المغرب", times.maghrib, provider.isDarkMode()),
                    _buildPrayerItem(context, "العشاء", times.isha, provider.isDarkMode()),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPrayerItem(BuildContext context, String name, String time, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? AppColors.yellowDark.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.yellow, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.yellow,
            ),
          ),
        ],
      ),
    );
  }
}
