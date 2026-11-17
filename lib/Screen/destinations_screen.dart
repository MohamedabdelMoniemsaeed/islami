import 'dart:async';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';
import 'package:islami/Screen/HomeTab/tasabeeh_screen.dart';
import 'package:islami/models/prayer_times_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

/// واجهة "إسلامي" الاحترافية مع بطاقة أوقات صلاة طبيعية ومتغيرة حسب الطقس (شروق، غروب، شمس، هلال، ليل ونهار)
class DestinationsScreen extends StatefulWidget {
  static const String routeName = "Destinations";

  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  Timer? _timer;
  StreamSubscription<Position>? _positionSubscription;
  String _remainingTime = "--:--:--";
  String _nextPrayerName = "الصلاة القادمة";
  String? _selectedPrayerName;

  @override
  void initState() {
    super.initState();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateCountdown());
    _initLocationTracking();
  }

  void _initLocationTracking() {
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 500, // تحديث الموقع كل 500 متر
      ),
    ).listen((Position position) {
      _refreshPrayerTimes(lat: position.latitude, lon: position.longitude);
    });
  }

  Future<void> _refreshPrayerTimes({double? lat, double? lon}) async {
    try {
      final times = await ApiService().getPrayerTimes(lat: lat, lon: lon);
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false).updateCachedPrayerTimes(times);
        setState(() {});
      }
    } catch (e) {
      debugPrint("Error auto-refreshing prayer times: $e");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positionSubscription?.cancel();
    super.dispose();
  }

  void _updateCountdown() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final times = provider.cachedPrayerTimes;
    if (times != null) {
      final now = DateTime.now();
      final result = _nextPrayer(times, now);
      final targetPrayer = _selectedPrayerName ?? result.name;
      final targetTimeStr = _getPrayerTime(times, targetPrayer);

      final diff = _calculateDiff(targetTimeStr, now);

      if (mounted) {
        setState(() {
          _nextPrayerName = result.name;
          _remainingTime = diff.isNegative ? "00:00:00" : _formatCountdown(diff);
        });
        try {
          final loc = (times.region.isNotEmpty) ? (times.region == times.country ? times.region : "${times.region}, ${times.country}") : "";
          HomeWidget.saveWidgetData<String>('next_prayer', _nextPrayerName);
          HomeWidget.saveWidgetData<String>('remaining_time', _remainingTime);
          HomeWidget.saveWidgetData<String>('location', loc);
          HomeWidget.updateWidget(androidName: 'PrayerWidgetProvider');
        } catch (_) {}
      }
    }
  }

  Duration _calculateDiff(String timeStr, DateTime now) {
    try {
      final format = DateFormat("HH:mm");
      final dt = format.parse(timeStr);
      var target = DateTime(now.year, now.month, now.day, dt.hour, dt.minute);
      if (target.isBefore(now)) {
        target = target.add(const Duration(days: 1));
      }
      return target.difference(now);
    } catch (_) {
      return Duration.zero;
    }
  }

  String _getPrayerTime(PrayerTimes times, String name) {
    switch (name) {
      case 'الفجر': return times.fajr;
      case 'الشروق': return times.sunrise;
      case 'الظهر': return times.dhuhr;
      case 'العصر': return times.asr;
      case 'المغرب': return times.maghrib;
      case 'العشاء': return times.isha;
      default: return times.fajr;
    }
  }

  ({String name, String time, DateTime target, bool isTomorrow}) _nextPrayer(PrayerTimes times, DateTime now) {
    try {
      final format = DateFormat("HH:mm");
      final prayers = [
        ('الفجر', times.fajr),
        ('الشروق', times.sunrise),
        ('الظهر', times.dhuhr),
        ('العصر', times.asr),
        ('المغرب', times.maghrib),
        ('العشاء', times.isha),
      ];

      for (var p in prayers) {
        try {
          final dt = format.parse(p.$2);
          final target = DateTime(now.year, now.month, now.day, dt.hour, dt.minute);
          if (target.isAfter(now)) {
            return (name: p.$1, time: p.$2, target: target, isTomorrow: false);
          }
        } catch (_) {}
      }

      final dt = format.parse(times.fajr);
      final target = DateTime(now.year, now.month, now.day + 1, dt.hour, dt.minute);
      return (name: 'الفجر', time: times.fajr, target: target, isTomorrow: true);
    } catch (_) {
      return (name: 'المغرب', time: '18:00', target: now.add(const Duration(hours: 1)), isTomorrow: false);
    }
  }

  String _formatCountdown(Duration diff) {
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  /// تدرجات لونية متناسقة مع ألوان ثيم البرنامج (ذهبي وكحلي داكن) حسب وقت اليوم
  List<Color> _getNaturalWeatherGradient(bool isDark) {
    final hour = DateTime.now().hour;
    if (isDark) {
      return [const Color(0xFF0D1B2A), const Color(0xFF141A2e), const Color(0xFF1a2540)];
    }
    if (hour >= 4 && hour < 6) {
      return [const Color(0xffB7935F), const Color(0xFFFACC10).withValues(alpha: 0.85), const Color(0xFFFFD700).withValues(alpha: 0.6)];
    } else if (hour >= 6 && hour < 17) {
      return [const Color(0xffB7935F).withValues(alpha: 0.85), const Color(0xFFE8D5B7), const Color(0xFFF5F0E8)];
    } else if (hour >= 17 && hour < 19) {
      return [const Color(0xffB7935F), const Color(0xFFFACC10).withValues(alpha: 0.7), const Color(0xFF141A2e)];
    } else {
      return [const Color(0xFF0D1B2A), const Color(0xFF141A2e), const Color(0xFF1a2540)];
    }
  }

  /// أيقونات طبيعية تعبيرية (شروق، شمس، غروب، هلال وقمر)
  IconData _getNaturalWeatherIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 6) return Icons.wb_twilight_rounded; // شروق
    if (hour >= 6 && hour < 17) return Icons.wb_sunny_rounded;    // شمس نهارية
    if (hour >= 17 && hour < 19) return Icons.nights_stay_rounded; // غروب
    // ليل وهلال/قمر حسب تقريب الأيام
    final day = DateTime.now().day;
    return (day > 10 && day < 22) ? Icons.nightlight_round : Icons.brightness_3_rounded;
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    final times = provider.cachedPrayerTimes;
    final hour = DateTime.now().hour;
    final bool isNight = hour < 4 || hour >= 19;

    final locationStr = (times != null && times.region.isNotEmpty)
        ? (times.region == times.country ? times.region : "${times.region}, ${times.country}")
        : "مصر";

    final hijriStr = (times != null && times.dateHijri.isNotEmpty)
        ? times.dateHijri
        : "15 جمادى الأولى 1447 هـ";

    final activePrayer = _selectedPrayerName ?? _nextPrayerName;

    final sortedDestinations = List<_Destination>.from(_destinations);
    sortedDestinations.sort((a, b) {
      int indexA = provider.destinationOrder.indexOf(a.id);
      int indexB = provider.destinationOrder.indexOf(b.id);
      return indexA.compareTo(indexB);
    });

    final prayerList = [
      ('الفجر', times?.fajr ?? '04:30'),
      ('الشروق', times?.sunrise ?? '06:00'),
      ('الظهر', times?.dhuhr ?? '12:00'),
      ('العصر', times?.asr ?? '15:15'),
      ('المغرب', times?.maghrib ?? '17:45'),
      ('العشاء', times?.isha ?? '19:00'),
    ];

    return ThemeSwitchingArea(
      child: Container(
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
            title: Text(
              "إسلامي",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            centerTitle: true,
            actions: [_ThemeToggle(isDark: isDark, provider: provider)],
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              children: [
                // البطاقة العلوية الاحترافية للطقس وأوقات الصلاة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _getNaturalWeatherGradient(isDark),
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // صف الموقع والتاريخ وأيقونة الطقس الطبيعية
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 700),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.scale(
                                      scale: value,
                                      child: Container(
                                        padding: const EdgeInsets.all(9),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.25),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          _getNaturalWeatherIcon(),
                                          color: Colors.amberAccent,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(width: 10),
                              Text(
                                locationStr,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () async {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("جاري تحديد الموقع عبر GPS ومواقات الصلاة...")),
                                  );
                                  try {
                                    final times = await ApiService().getPrayerTimes();
                                    if (context.mounted) {
                                      Provider.of<AppProvider>(context, listen: false).updateCachedPrayerTimes(times);
                                      setState(() {});
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("تم تحديد الموقع ومواقيت الصلاة عبر GPS بنجاح!"),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("تعذر تحديد الموقع: $e"), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.my_location, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              hijriStr,
                              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // العد التنازلي للصلاة المحددة / القادمة
                      Center(
                        child: Column(
                          children: [
                            Text(
                              _selectedPrayerName == null
                                  ? "المتبقي على أذان $_nextPrayerName"
                                  : "المتبقي على أذان $_selectedPrayerName",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _remainingTime,
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 2,
                                shadows: [Shadow(color: Colors.black38, blurRadius: 6)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white38, height: 1),
                      const SizedBox(height: 12),

                      // شريط أزرار الصلوات الستة التفاعلي الطبيعي
                      SizedBox(
                        height: 75,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: prayerList.length,
                          itemBuilder: (context, index) {
                            final prayer = prayerList[index];
                            final prayerName = prayer.$1;
                            final prayerTime = prayer.$2;
                            final isSelected = activePrayer == prayerName;
                            final isNext = _nextPrayerName == prayerName && _selectedPrayerName == null;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPrayerName = prayerName;
                                  _updateCountdown();
                                });
                              },
                              child: Container(
                                width: 74,
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withValues(alpha: 0.35)
                                      : Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: (isSelected || isNext) ? Colors.amberAccent : Colors.white24,
                                    width: (isSelected || isNext) ? 2.5 : 1,
                                  ),
                                  boxShadow: (isSelected || isNext)
                                      ? [BoxShadow(color: Colors.amberAccent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      prayerName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: (isSelected || isNext) ? FontWeight.bold : FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      prayerTime,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withValues(alpha: 0.95),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // شبكة الأيقونات الدائرية بأسلوب طبيعي متناسق ومريح للعين
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: sortedDestinations.length,
                  itemBuilder: (context, i) => _buildTile(context, sortedDestinations[i], isDark),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _Destination d, bool isDark) {
    // ألوان طبيعية متناسقة وراقية للعين (ذهبي برونزي طبيعي وأبيض ناعم)
    final naturalGold = isDark ? const Color(0xFFD4AF37) : const Color(0xFFC5A059);
    final bg = isDark ? const Color(0xFF1E2229) : Colors.white;

    return Column(
      key: ValueKey(d.id),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () => _open(context, d),
            child: Container(
              width: 75,
              height: 75,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: Border.all(color: naturalGold, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: d.crescent
                  ? _CrescentStar(gold: naturalGold, bg: bg)
                  : Icon(d.icon, color: naturalGold, size: 32),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  void _open(BuildContext context, _Destination d) async {
    if (d.homeTab != null) {
      Navigator.pushNamed(context, HomeScreen.routeName, arguments: d.homeTab);
    } else if (d.route == SurahIndexScreen.routeName) {
      final page = await Navigator.pushNamed(context, d.route!);
      if (page is int && context.mounted) {
        Provider.of<AppProvider>(context, listen: false).requestJumpToPage(page - 1);
        Navigator.pushReplacementNamed(context, HomeScreen.routeName, arguments: 0);
      }
    } else {
      Navigator.pushNamed(context, d.route!, arguments: d.routeArgs);
    }
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final AppProvider provider;
  const _ThemeToggle({required this.isDark, required this.provider});

  @override
  Widget build(BuildContext context) {
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: const Color(0xFFC5A059), size: 26),
          tooltip: isDark ? "الوضع الفاتح" : "الوضع الداكن",
          onPressed: () {
            final target = isDark ? ThemeMode.light : ThemeMode.dark;
            provider.changeTheme(target);
            ThemeSwitcher.of(ctx).changeTheme(theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme);
          },
        ),
      ),
    );
  }
}

class _Destination {
  final String id;
  final String label;
  final IconData icon;
  final bool crescent;
  final int? homeTab;
  final String? route;
  final Object? routeArgs;

  const _Destination(this.id, this.label,
      {this.icon = Icons.circle,
      this.crescent = false,
      this.homeTab,
      this.route,
      this.routeArgs});
}

const _destinations = [
  _Destination("quran", "القرآن", icon: Icons.auto_stories, homeTab: 0),
  _Destination("radio", "الراديو", icon: Icons.radio, homeTab: 1),
  _Destination("prayer", "مواقيت الصلاة", crescent: true, homeTab: 2),
  _Destination("settings", "الإعدادات", icon: Icons.settings, homeTab: 3),
  _Destination("surah_index", "فهرس السور", icon: Icons.menu_book, route: SurahIndexScreen.routeName),
  _Destination("tafsir_index", "فهرس التفسير", icon: Icons.translate, route: TafsirIndexScreen.routeName),
  _Destination("reciter", "الشيخ المنشاوي",
      icon: IconData(0xe491, fontFamily: 'MaterialIcons'),
      route: ReciterAudioScreen.routeName,
      routeArgs: {'reciter_id': 112}),
  _Destination("azkar", "الأذكار", icon: Icons.auto_awesome, route: AzkarScreen.routeName),
  _Destination("duas", "الأدعية", icon: Icons.favorite, route: DuasScreen.routeName),
  _Destination("tasabeeh", "التسابيح", icon: Icons.spa, route: TasabeehScreen.routeName),
];

class _CrescentStar extends StatelessWidget {
  final Color gold;
  final Color bg;

  const _CrescentStar({required this.gold, required this.bg});

  @override
  Widget build(BuildContext context, {Key? key}) {
    return SizedBox(
      width: 64,
      height: 64,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle, color: gold),
          ),
          Transform.translate(
            offset: const Offset(10, -8),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
            ),
          ),
          Transform.translate(
            offset: const Offset(14, -14),
            child: Icon(Icons.star_rounded, color: gold, size: 14),
          ),
        ],
      ),
    );
  }
}
