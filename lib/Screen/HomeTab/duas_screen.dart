import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/Screen/HomeTab/duas.dart';
import 'package:provider/provider.dart';

class DuasScreen extends StatelessWidget {
  static const String routeName = "DuasScreen";
  const DuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() ? AppImage.backgroundDark : AppImage.backgroundHome
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26), tooltip: "رجوع", onPressed: () => Navigator.maybePop(context)),
          title: const Text("الأدعية", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow)),
          centerTitle: true,
          actions: [_ThemeToggle()],
        ),
        body: const DuasTab(),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(width: 48, height: 48, child: IconButton(
        icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.yellow, size: 26),
        tooltip: isDark ? "الوضع الفاتح" : "الوضع الداكن",
        onPressed: () {
          provider.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
          ThemeSwitcher.of(ctx).changeTheme(theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme);
        },
      )),
    );
  }
}
