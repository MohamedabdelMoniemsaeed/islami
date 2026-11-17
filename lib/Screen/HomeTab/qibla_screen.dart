import 'dart:math';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class QiblaScreen extends StatefulWidget {
  static const String routeName = "QiblaScreen";

  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaDirection = 0.0;
  String _statusMessage = "جاري تحديد اتجاه القبلة عبر الـ GPS...";
  bool _isLoading = true;

  // إحداثيات الكعبة المشرفة (مكة المكرمة)
  static const double kaabaLat = 21.4225;
  static const double kaabaLon = 39.8262;

  @override
  void initState() {
    super.initState();
    _calculateQibla();
  }

  Future<void> _calculateQibla() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = "خدمة الموقع (GPS) غير مفعلة.";
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusMessage = "تم رفض إذن الوصول للموقع.";
            _isLoading = false;
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double userLat = position.latitude;
      double userLon = position.longitude;

      // حساب اتجاه القبلة (Bearing)
      double lat1 = userLat * pi / 180;
      double lon1 = userLon * pi / 180;
      double lat2 = kaabaLat * pi / 180;
      double lon2 = kaabaLon * pi / 180;

      double dLon = lon2 - lon1;

      double y = sin(dLon) * cos(lat2);
      double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
      double radians = atan2(y, x);

      double bearing = radians * 180 / pi;
      bearing = (bearing + 360) % 360;

      setState(() {
        _qiblaDirection = bearing;
        _statusMessage = "تم تحديد اتجاه الكعبة المشرفة بدقة 🕋";
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = "تعذر تحديد الموقع: $e";
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    final gold = isDark ? AppColors.blackDark : AppColors.yellow;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(isDark ? AppImage.backgroundDark : AppImage.backgroundHome),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26),
            tooltip: "رجوع",
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            "اتجاه القبلة",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow),
          ),
          centerTitle: true,
          actions: [_ThemeToggle()],
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _statusMessage,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const CircularProgressIndicator(color: AppColors.yellow)
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // إطار البوصلة
                            Container(
                              width: 280,
                              height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark ? AppColors.yellowDark : Colors.white,
                                border: Border.all(color: gold, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.explore, size: 220, color: Colors.black12),
                              ),
                            ),
                            // مؤشر القبلة (سهم الكعبة)
                            Transform.rotate(
                              angle: (_qiblaDirection * pi / 180),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.navigation, color: gold, size: 60),
                                  const SizedBox(height: 140),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                const Icon(Icons.mosque, color: Colors.redAccent, size: 36),
                                const SizedBox(height: 8),
                                Text(
                                  "${_qiblaDirection.toStringAsFixed(1)}°",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() => _isLoading = true);
                      _calculateQibla();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("تحديث اتجاه القبلة", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.yellow, size: 26),
          tooltip: isDark ? "الوضع الفاتح" : "الوضع الداكن",
          onPressed: () {
            provider.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
            ThemeSwitcher.of(ctx).changeTheme(theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme);
          },
        ),
      ),
    );
  }
}
