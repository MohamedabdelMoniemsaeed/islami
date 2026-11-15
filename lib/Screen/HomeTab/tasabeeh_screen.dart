import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:provider/provider.dart';
import 'package:islami/dezeen/shiar.dart';

class TasabeehScreen extends StatefulWidget {
  static const String routeName = "TasabeehScreen";

  const TasabeehScreen({super.key});

  @override
  State<TasabeehScreen> createState() => _TasabeehScreenState();
}

class _TasabeehScreenState extends State<TasabeehScreen> {
  final List<Map<String, dynamic>> _tasabeehList = [
    {
      "text": "سُبْحَانَ اللَّهِ",
      "target": 100,
      "count": 0,
      "description": "يكتب له ألف حسنة أو يحط عنه ألف خطيئة."
    },
    {
      "text": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ",
      "target": 100,
      "count": 0,
      "description": "حُطَّتْ خَطَايَاهُ وَإِنْ كَانَتْ مِثْلَ زَبَدِ الْبَحْرِ."
    },
    {
      "text": "سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ",
      "target": 100,
      "count": 0,
      "description": "تَمْلَآنِ مَا بَيْنَ السَّمَاوَاتِ وَالْأَرْضِ."
    },
    {
      "text": "سُبْحَانَ اللهِ العَظِيمِ وَبِحَمْدِهِ",
      "target": 100,
      "count": 0,
      "description": "غرست له نخلة في الجنة."
    },
    {
      "text": "سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ",
      "target": 100,
      "count": 0,
      "description": "ثقيلتان في الميزان حبيبتان إلى الرحمن."
    },
    {
      "text": "لَا إلَه إلّا اللهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءِ قَدِيرِ",
      "target": 100,
      "count": 0,
      "description": "كانت له عدل عشر رقاب، وكتبت له مئة حسنة."
    },
    {
      "text": "لَا حَوْلَ وَلا قُوَّةَ إِلا بِاللَّهِ",
      "target": 100,
      "count": 0,
      "description": "كنز من كنوز الجنة."
    },
    {
      "text": "الْحَمْدُ للّهِ رَبِّ الْعَالَمِينَ",
      "target": 100,
      "count": 0,
      "description": "تملأ ميزان العبد بالحسنات."
    },
    {
      "text": "أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ",
      "target": 100,
      "count": 0,
      "description": "مائة حسنة ومحيت عنه مئة سيئة."
    },
    {
      "text": "سُبْحَانَ الْلَّهِ، وَالْحَمْدُ لِلَّهِ، وَلَا إِلَهَ إِلَّا الْلَّهُ، وَالْلَّهُ أَكْبَرُ",
      "target": 100,
      "count": 0,
      "description": "أحب الكلام إلى الله الباقيات الصالحات."
    },
    {
      "text": "اللَّهُ أَكْبَرُ",
      "target": 100,
      "count": 0,
      "description": "كتبت له عشرون حسنة وحطت عنه عشرون سيئة."
    }
  ];

  void _incrementCount(int index) {
    setState(() {
      _tasabeehList[index]["count"] = (_tasabeehList[index]["count"] as int) + 1;
    });
  }

  void _resetCount(int index) {
    setState(() {
      _tasabeehList[index]["count"] = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            isDark ? AppImage.backgroundDark : AppImage.backgroundHome,
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26),
            tooltip: "رجوع",
            onPressed: () => Navigator.maybePop(context),
          ),
          title: const Text(
            "التسابيح",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow),
          ),
          centerTitle: true,
          actions: [_ThemeToggle()],
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _tasabeehList.length,
          itemBuilder: (context, index) {
            final item = _tasabeehList[index];
            final count = item["count"] as int;
            final target = item["target"] as int;
            final progress = (count / target).clamp(0.0, 1.0);

            return Card(
              color: isDark ? AppColors.yellowDark : Colors.white.withValues(alpha: 0.95),
              margin: const EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.yellow.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item["text"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.rtl,
                    ),
                    if ((item["description"] as String).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item["description"],
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white70 : Colors.grey[700],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.yellow),
                      minHeight: 6,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.grey),
                          tooltip: "إعادة العداد",
                          onPressed: () => _resetCount(index),
                        ),
                        InkWell(
                          onTap: () => _incrementCount(index),
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.yellow,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.yellow.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Text(
                              "$count / $target",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 40), // balancing space for refresh button
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(
        width: 48,
        height: 48,
        child: IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode, color: AppColors.yellow, size: 26),
          tooltip: isDark ? "الوضع الفاتح" : "الوضع الداكن",
          onPressed: () {
            provider.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
            ThemeSwitcher.of(ctx).changeTheme(theme: isDark ? Apptheme.lightTheme : Apptheme.darkTheme);
          },
        ),
      ),
    );
  }
}
