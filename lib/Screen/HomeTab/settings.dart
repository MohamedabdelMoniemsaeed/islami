import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../dezeen/shiar.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  final _shorebirdUpdater = ShorebirdUpdater();
  bool _isCheckingForUpdate = false;
  String _version = "";

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
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
          _showSnackBar("يوجد تحديث جديد.. جاري التحميل الآن");
          await _shorebirdUpdater.update();
          _showSnackBar("تم تحميل التحديث! يرجى إغلاق التطبيق وفتحه مجدداً");
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                locale.mode,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Switch(
                value: provider.isDarkMode(),
                onChanged: (isDark) {
                  provider.changeTheme(isDark ? ThemeMode.dark : ThemeMode.light);
                },
              ),
            ],
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
