import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/Screen/HomeTab/prayer_times.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';
import 'package:islami/dezeen/surah_pages.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initPrayerNotifications();
    // جلب قائمة السور فور فتح البرنامج لتكون جاهزة في الفهرس
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadSurahs();
    });
  }

  Future<void> _initPrayerNotifications() async {
    try {
      final times = await ApiService().getPrayerTimes();
      await NotificationService().scheduleAllPrayers(times);
    } catch (e) {
      debugPrint("Error initializing prayer notifications: $e");
    }
  }

  final List<Widget> tabs = [
    const QuranTab(),
    const RadioTab(),
    const PrayerTimesTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var locale = AppLocalizations.of(context)!;
    bool isDark = provider.isDarkMode();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              isDark ? AppImage.backgroundDark : AppImage.backgroundHome),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.transparent,
        drawer: _buildAppDrawer(context, provider, isDark),
        body: SafeArea(
          child: Stack(
            children: [
              IndexedStack(
                index: currentIndex,
                children: tabs,
              ),
              // زر القائمة (ثلاث شرط) يظهر في كل الصفحات ما عدا الإعدادات
              if (currentIndex != 3)
                Positioned(
                  top: 20,
                  right: 15,
                  child: IconButton(
                    icon:
                        const Icon(Icons.menu, color: AppColors.yellow, size: 35),
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 70,
          margin: const EdgeInsets.only(left: 15, right: 15, bottom: 15),
          decoration: BoxDecoration(
            color: isDark ? AppColors.yellowDark : Colors.white,
            borderRadius: BorderRadius.circular(35),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDynamicNavItem(0, Icons.book, locale.quran, isDark),
              _buildDynamicNavItem(1, Icons.radio, locale.radio, isDark),
              _buildDynamicNavItem(
                  2, Icons.access_time_filled, locale.prayerTimes, isDark),
              _buildDynamicNavItem(3, Icons.settings, locale.settings, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppDrawer(
      BuildContext context, AppProvider provider, bool isDark) {
    return Drawer(
      child: Container(
        color: isDark ? AppColors.yellowDark : Colors.white,
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                  color: isDark ? AppColors.yellowDark : AppColors.yellow),
              child: Center(
                  child: Image.asset('assets/images/quran.png', height: 80)),
            ),
            _buildDrawerItem(Icons.menu_book, "فهرس السور", () async {
              Navigator.pop(context);
              final selectedPage =
                  await Navigator.pushNamed(context, SurahIndexScreen.routeName);
              if (selectedPage != null && selectedPage is int) {
                // نحتاج لإبلاغ شاشة القرآن بالانتقال للصفحة
                // سنقوم بتغيير التبويب للقرآن أولاً ثم التوجيه
                setState(() => currentIndex = 0);
                // استخدام Provider لإرسال رقم الصفحة المطلوب
                provider.updateQuranPage(selectedPage);
              }
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.translate, "تفسير الصفحة الحالية", () {
              Navigator.pop(context);
              _showCurrentTafsir(context, provider, isDark);
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.list_alt, "فهرس التفسير (كل السور)", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, TafsirIndexScreen.routeName);
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.person, "الشيخ محمد صديق المنشاوي", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, ReciterAudioScreen.routeName,
                  arguments: {'reciter_id': 112});
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.auto_awesome, "الأذكار", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AzkarScreen.routeName);
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.favorite, "الأدعية", () {
              Navigator.pop(context);
              Navigator.pushNamed(context, DuasScreen.routeName);
            }, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon, String title, VoidCallback onTap, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: isDark ? AppColors.blackDark : AppColors.yellow),
      title: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black)),
      onTap: onTap,
    );
  }

  void _showCurrentTafsir(
      BuildContext context, AppProvider provider, bool isDark) {
    int currentSuraNum = 1;
    String currentSuraName = "الفاتحة";

    if (provider.surahs.isNotEmpty) {
      for (var surah in provider.surahs) {
        try {
          int surahNum = int.parse(surah['number'].toString());
          int surahPage = SurahPages.startPages[surahNum - 1];
          if (surahPage <= (provider.currentQuranPage + 1)) {
            currentSuraNum = surahNum;
            currentSuraName = surah['name_ar'] ?? "سورة";
          } else {
            break;
          }
        } catch (e) {
          continue;
        }
      }
    }

    Navigator.pushNamed(
      context,
      TafsirDetailsScreen.routeName,
      arguments: {
        'number': currentSuraNum,
        'name': currentSuraName,
      },
    );
  }

  Widget _buildDynamicNavItem(int index, IconData icon, String label, bool isDark) {
    bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: isSelected ? 60 : 50,
        height: isSelected ? 60 : 50,
        decoration: isSelected
            ? BoxDecoration(
                color: isDark ? AppColors.blackDark : AppColors.yellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isDark ? AppColors.blackDark : AppColors.yellow).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? (isDark ? AppColors.yellowDark : Colors.white)
                  : Colors.grey,
              size: isSelected ? 30 : 26,
            ),
            if (!isSelected)
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              )
          ],
        ),
      ),
    );
  }
}

