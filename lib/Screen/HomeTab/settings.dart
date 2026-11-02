import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import '../../dezeen/shiar.dart';
import '../../dezeen/theme.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _shorebirdUpdater = ShorebirdUpdater();
  final ApiService _apiService = ApiService();
  bool _isCheckingForUpdate = false;
  String _version = "";

  // إعدادات الأذان (محمّلة من SharedPreferences)
  bool _adhanMaster = true;
  Set<String>? _adhanPrayers;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _loadAdhanSettings();
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = "${packageInfo.version} (${packageInfo.buildNumber})";
    });
  }

  Future<void> _checkForUpdate() async {
    setState(() {
      _isCheckingForUpdate = true;
    });

    try {
      if (!_shorebirdUpdater.isAvailable) {
        _showSnackBar("Shorebird غير متاح (تأكد أنك تستخدم نسخة Release)");
        return;
      }

      final status = await _shorebirdUpdater.checkForUpdate();
      
      if (!mounted) return;

      switch (status) {
        case UpdateStatus.upToDate:
          _showSnackBar("تطبيقك محدث لآخر إصدار بالفعل");
          break;
        case UpdateStatus.outdated:
          // السبينر في الزرار بيبيّن التحميل، فمش محتاجين سناك بار نصي
          await _shorebirdUpdater.update();
          _showSnackBar("تم تحميل التحديث! أغلق التطبيق وافتحه تاني هيتم تطبيقه");
          break;
        case UpdateStatus.restartRequired:
          _showSnackBar("يوجد تحديث محمل بالفعل، يرجى إعادة تشغيل التطبيق");
          break;
        case UpdateStatus.unavailable:
          _showSnackBar("خدمة التحديث غير متوفرة حالياً");
          break;
      }
    } catch (e) {
      _showSnackBar("حدث خطأ أثناء فحص التحديثات: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingForUpdate = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // ===== إعدادات الأذان =====

  Future<void> _loadAdhanSettings() async {
    final service = NotificationService();
    final master = await service.isMasterAdhanEnabled();
    final states = await service.getPrayerStates();
    if (!mounted) return;
    setState(() {
      _adhanMaster = master;
      _adhanPrayers =
          states.entries.where((e) => e.value).map((e) => e.key).toSet();
    });
  }

  Future<void> _onMasterAdhanToggle(bool value) async {
    setState(() => _adhanMaster = value);
    await NotificationService().setMasterAdhanEnabled(value);
    if (value) {
      await _scheduleEnabledAdhan("تم تفعيل الأذان");
    } else {
      await NotificationService().cancelAll();
      _showSnackBar("تم إيقاف الأذان");
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
    await NotificationService().setPrayerEnabled(prayer, value);
    if (value) {
      await _scheduleEnabledAdhan("تم تفعيل أذان $name");
    } else {
      await NotificationService().cancelPrayerNotification(prayer);
      _showSnackBar("تم إيقاف أذان $name");
    }
  }

  /// إعادة جدولة صلاوات اليوم حسب الإعدادات الحالية
  Future<void> _scheduleEnabledAdhan(String successMessage) async {
    try {
      final times = await _apiService.getPrayerTimes();
      await NotificationService().scheduleEnabledPrayers(times);
      _showSnackBar(successMessage);
    } catch (_) {
      _showSnackBar("تم الحفظ — الأذان بيتفعّل أول ما تكون بيانات المواقيت متاحة");
    }
  }

  Widget _buildAdhanSwitchRow(String label, bool value, ValueChanged<bool>? onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyLarge),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var locale = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 40),
          ThemeSwitcher.withTheme(
            builder: (context, switcher, _) {
              final isDark = provider.isDarkMode();
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    locale.mode,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Switch(
                    value: isDark,
                    onChanged: (_) {
                      final target = isDark ? ThemeMode.light : ThemeMode.dark;
                      // 1) نبني حالة الـ provider لباقي التطبيق (اللي بيقرأ isDarkMode)
                      provider.changeTheme(target);
                      // 2) مشغل الحركة في الـ ThemeProvider
                      switcher.changeTheme(
                        theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme,
                      );
                    },
                  ),
                ],
              );
            },
          ),
          // ===== قسم إعدادات الأذان =====
          const SizedBox(height: 30),
          const Text(
            "اذان الصلاة",
            style: TextStyle(
              color: AppColors.yellow,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "صوت الاذان",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Text(
                "الافتراضي",
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildAdhanSwitchRow("تشغيل الاذان", _adhanMaster, _onMasterAdhanToggle),
          const SizedBox(height: 10),
          for (final prayer in NotificationService.prayerNames.keys)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildAdhanSwitchRow(
                NotificationService.prayerNames[prayer]!,
                _adhanMaster && (_adhanPrayers?.contains(prayer) ?? true),
                _adhanMaster
                    ? (v) => _onPrayerToggle(
                          prayer, NotificationService.prayerNames[prayer]!, v,
                        )
                    : null,
              ),
            ),
          const Spacer(),
          if (_isCheckingForUpdate)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _checkForUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.yellow,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                locale.checkForUpdates,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(height: 10),
          Text(
            "${locale.version}: $_version",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
