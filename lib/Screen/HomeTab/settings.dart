import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({super.key});

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
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

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();

    return Container(
      color: Colors.transparent,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Image.asset('assets/images/quran.png', height: 90),
            ),
            const SizedBox(height: 30),
            _infoCard(isDark, "الوصف", "تطبيق إسلامي شامل يحتوي على القرآن الكريم، مواقيت الصلاة، الراديو، الأذكار والأدعية، والتفسير"),
            const SizedBox(height: 12),
            _infoCard(isDark, "الترخيص", "جميع الحقوق محفوظة © 2026"),
            const SizedBox(height: 40),
            Text(
              _version.isNotEmpty ? "الإصدار $_version" : "",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(bool isDark, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.yellowDark : Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
