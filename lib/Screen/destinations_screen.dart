import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';
import 'package:islami/Screen/HomeTab/laylat_al_qadr_screen.dart';
import 'package:provider/provider.dart';

/// شاشة الوجهات: أيقونات دائرية (اسم تحت كل أيقونة) تفتح الشاشات الموجودة
/// من غير أي تعديل عليها، وبتغيّر ألوانها مع الثيم.
class DestinationsScreen extends StatelessWidget {
  static const String routeName = "Destinations";

  const DestinationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();

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
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                  Icons.arrow_back,
                  color: isDark ? AppColors.blackDark : AppColors.yellow,
                  size: 28),
            ),
            title: Text(
              "الوجهات",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          body: SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 24,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: _destinations.length,
              itemBuilder: (context, i) => _buildTile(context, _destinations[i], isDark),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () => _open(context, d),
            child: Container(
              width: 110,
              height: 110,
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
                  : Icon(d.icon, color: gold, size: 48),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          d.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  void _open(BuildContext context, _Destination d) {
    if (d.homeTab != null) {
      Navigator.pushNamed(context, HomeScreen.routeName, arguments: d.homeTab);
    } else {
      Navigator.pushNamed(context, d.route!, arguments: d.routeArgs);
    }
  }
}

class _Destination {
  final String label;
  final IconData icon;
  final bool crescent;
  final int? homeTab;
  final String? route;
  final Object? routeArgs;

  const _Destination(this.label,
      {this.icon = Icons.circle,
      this.crescent = false,
      this.homeTab,
      this.route,
      this.routeArgs});
}

const _destinations = [
  _Destination("القرآن", icon: Icons.auto_stories, homeTab: 0),
  _Destination("الراديو", icon: Icons.radio, homeTab: 1),
  _Destination("مواقيت الصلاة", crescent: true, homeTab: 2),
  _Destination("الإعدادات", icon: Icons.settings, homeTab: 3),
  _Destination("فهرس السور", icon: Icons.menu_book, route: SurahIndexScreen.routeName),
  _Destination("فهرس التفسير", icon: Icons.translate, route: TafsirIndexScreen.routeName),
  _Destination("الشيخ المنشاوي",
      icon: Icons.person,
      route: ReciterAudioScreen.routeName,
      routeArgs: {'reciter_id': 112}),
  _Destination("الأذكار", icon: Icons.auto_awesome, route: AzkarScreen.routeName),
  _Destination("الأدعية", icon: Icons.favorite, route: DuasScreen.routeName),
  _Destination("ليلة القدر", icon: Icons.stars, route: LaylatAlQadrScreen.routeName),
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
          // دائرة القصّ: لونها = خلفية الدائرة فبتنقص جزء من الهلالية بصرياً
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
