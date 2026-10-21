import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';
import 'package:islami/Screen/HomeTab/laylat_al_qadr_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const SurahIndexScreen(),
    const TafsirIndexScreen(),
    const AzkarScreen(),
    const DuasScreen(),
    const ReciterAudioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تطبيق إسلامي'),
        actions: [
          IconButton(
            icon: Icon(provider.mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => provider.toggleTheme(),
          ),
          IconButton(
            icon: const Icon(Icons.nightlight),
            onPressed: () => Navigator.pushNamed(context, LaylatAlQadrScreen.routeName),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Color(0xFF202020)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.menu_book, size: 48, color: Color(0xFFE2BE7F)),
                  SizedBox(height: 12),
                  Text('تطبيق إسلامي', style: TextStyle(color: Color(0xFFE2BE7F), fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.menu_book),
              title: const Text('فهرس السور'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 0);
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('التفسير'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 1);
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('الأذكار'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 2);
              },
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('الأدعية'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 3);
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio),
              title: const Text('الإذاعة'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedIndex = 4);
              },
            ),
            ListTile(
              leading: const Icon(Icons.nightlight_round),
              title: const Text('ليلة القدر'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, LaylatAlQadrScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFFE2BE7F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'القرآن'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'التفسير'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'الأذكار'),
          BottomNavigationBarItem(icon: Icon(Icons.format_quote), label: 'الأدعية'),
          BottomNavigationBarItem(icon: Icon(Icons.radio), label: 'الإذاعة'),
        ],
      ),
    );
  }
}
