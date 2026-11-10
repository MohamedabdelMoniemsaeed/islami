import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/Screen/HomeTab/prayer_times.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/surah_pages.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";
  final int startTab;

  const HomeScreen({super.key, this.startTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int currentIndex = widget.startTab;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initPrayerNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadSurahs();
    });
  }

  Future<void> _initPrayerNotifications() async {
    try {
      final times = await ApiService().getPrayerTimes();
      if (mounted) {
        Provider.of<AppProvider>(context, listen: false)
            .updateCachedPrayerTimes(times);
      }
      await NotificationService().scheduleEnabledPrayers(times);
    } catch (e) {
      debugPrint("Error initializing prayer notifications: $e");
    }
  }

  void _openQuranDrawer() {
    _scaffoldKey.currentState?.openDrawer();
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
    final bool isQuran = currentIndex == 0;

    return ThemeSwitchingArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(isDark ? AppImage.backgroundDark : AppImage.backgroundHome),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          key: _scaffoldKey,
          drawer: _buildAppDrawer(context, provider, isDark),
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [_ThemeToggle(isDark: isDark, provider: provider)],
            leading: isQuran
                ? IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.yellow, size: 26),
                    tooltip: "القائمة",
                    onPressed: _openQuranDrawer,
                  )
                : IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26),
                    tooltip: "رجوع",
                    onPressed: () => Navigator.maybePop(context),
                  ),
            title: Text(
              _tabTitles[currentIndex],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow),
            ),
            centerTitle: true,
          ),
          body: SafeArea(
            child: IndexedStack(
              index: currentIndex,
              children: tabs,
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
                _buildNavItem(0, Icons.book, locale.quran, isDark),
                _buildNavItem(1, Icons.radio, locale.radio, isDark),
                _buildNavItem(2, Icons.access_time_filled, "مواقيت", isDark),
                _buildNavItem(3, Icons.settings, locale.settings, isDark),
              ],
            ),
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
                setState(() => currentIndex = 0);
                provider.requestJumpToPage(selectedPage - 1);
              }
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.bookmark, "حفظ علامة", () {
              provider.saveBookmark();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("تم حفظ العلامة بنجاح")),
              );
            }, isDark),
            const Divider(),
            _buildDrawerItem(Icons.bookmark_added, "انتقال إلى العلامة", () {
              if (provider.bookmarkedPage != null) {
                setState(() => currentIndex = 0);
                provider.requestJumpToPage(provider.bookmarkedPage!);
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("لا توجد علامة محفوظة")),
                );
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

  Widget _buildNavItem(int index, IconData icon, String label, bool isDark) {
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
              color: isSelected ? (isDark ? AppColors.yellowDark : Colors.white) : Colors.grey,
              size: isSelected ? 30 : 26,
            ),
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
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
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.yellow, size: 26),
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

const _tabTitles = ["القرآن الكريم", "الراديو", "مواقيت الصلاة", "الإعدادات"];
