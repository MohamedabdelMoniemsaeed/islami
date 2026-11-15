import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
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
import 'package:provider/provider.dart';

/// شاشة الوجهات: أيقونات دائرية (اسم تحت كل أيقونة) تفتح الشاشات الموجودة
/// من غير أي تعديل عليها، وبتغيّر ألوانها مع الثيم.
class DestinationsScreen extends StatefulWidget {
  static const String routeName = "Destinations";

  const DestinationsScreen({super.key});

  @override
  State<DestinationsScreen> createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();

    // Sort destinations based on provider order
    final sortedDestinations = List<_Destination>.from(_destinations);
    sortedDestinations.sort((a, b) {
      int indexA = provider.destinationOrder.indexOf(a.id);
      int indexB = provider.destinationOrder.indexOf(b.id);
      return indexA.compareTo(indexB);
    });

    return ThemeSwitchingArea(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                AssetImage(isDark ? AppImage.backgroundDark : AppImage.backgroundHome),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              "الوجهات",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            actions: [_ThemeToggle(isDark: isDark, provider: provider)],
          ),
          body: SafeArea(
            child: ReorderableGridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: sortedDestinations.length,
              itemBuilder: (context, i) => _buildTile(context, sortedDestinations[i], isDark),
              onReorder: (oldIndex, newIndex) {
                provider.reorderDestination(oldIndex, newIndex);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, _Destination d, bool isDark) {
    final gold = isDark ? AppColors.blackDark : AppColors.yellow;
    final bg = isDark ? AppColors.yellowDark : Colors.white;

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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bg,
                border: Border.all(color: gold, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: d.crescent
                  ? _CrescentStar(gold: gold, bg: bg)
                  : Icon(d.icon, color: gold, size: 36),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          d.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
          textAlign: TextAlign.center,
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
      icon: Icons.person,
      route: ReciterAudioScreen.routeName,
      routeArgs: {'reciter_id': 112}),
  _Destination("azkar", "الأذكار", icon: Icons.auto_awesome, route: AzkarScreen.routeName),
  _Destination("duas", "الأدعية", icon: Icons.favorite, route: DuasScreen.routeName),
  _Destination("tasabeeh", "التسابيح", icon: Icons.spa, route: TasabeehScreen.routeName),
];

/// هلال ونجمة مرسومة بدائرتين (القصّية بلون خلفية الدائرة عشان تدمج) + نجمة،
/// مطابقة للستايل في الصورة.
class _CrescentStar extends StatelessWidget {
  final Color gold;
  final Color bg;

  const _CrescentStar({required this.gold, required this.bg});

  @override
  Widget build(BuildContext context) {
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
          // دائرة القصّ: لونها = خلفية الدائرة فبتنقص جزء من الهلالية بصرياُ
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
