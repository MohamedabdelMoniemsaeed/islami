import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/ahadeth.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/Screen/HomeTab/prayer_times.dart';
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
    const RadioTab(), // مدمج معه التفسير الآن
    const PrayerTimesTab(),
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
              icon: const Icon(Icons.book),
              label: locale.quran,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.format_list_bulleted),
              label: locale.ahadeth,
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(AppImage.icRadio)),
              label: "${locale.radio} & ${locale.tafasir}",
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time_filled),
              label: locale.prayerTimes,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome),
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
