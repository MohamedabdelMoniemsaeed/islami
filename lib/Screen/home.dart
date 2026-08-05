import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/duas.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/Screen/HomeTab/prayer_times.dart';
import 'package:islami/Screen/HomeTab/azkar.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initPrayerNotifications();
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
    const DuasTab(),
    const RadioTab(),
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
          fit: BoxFit.cover, // تغيير إلى cover لتغطية الشاشة بالكامل
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // جعل خلفية السكافولد شفافة لتظهر الصورة
        body: SafeArea(
          child: IndexedStack(
            index: currentIndex,
            children: tabs,
          ),
        ),
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
              icon: const Icon(Icons.favorite),
              label: "الأدعية",
            ),
            BottomNavigationBarItem(
              icon: const ImageIcon(AssetImage(AppImage.icRadio)),
              label: locale.radio,
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

