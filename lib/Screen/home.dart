import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/ahadeth.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/Screen/HomeTab/prayer_times.dart';
import 'package:islami/Screen/HomeTab/tafasir.dart';
import 'package:islami/Screen/HomeTab/azkar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  
  final List<Widget> tabs = [
    const QuranTab(),
    const AhadethTab(),
    const RadioTab(),
    const PrayerTimesTab(),
    const TafasirTab(),
    const AzkarTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var locale = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() 
                ? AppImage.backgroundDark 
                : AppImage.backgroundHome
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        body: SafeArea(child: tabs[currentIndex]),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(AppImage.icQuran)),
              label: locale.quran,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(AppImage.icAhadeth)),
              label: locale.ahadeth,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(AppImage.icRadio)),
              label: locale.radio,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time),
              label: locale.prayerTimes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book),
              label: locale.tafasir,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_stories),
              label: locale.azkar,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              label: locale.settings,
            ),
          ],
        ),
      ),
    );
  }
}
