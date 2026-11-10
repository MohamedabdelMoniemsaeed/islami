import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/sura_name.dart'; // القائمة الاحتياطية
import 'package:provider/provider.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';

class TafsirIndexScreen extends StatefulWidget {
  static const String routeName = "TafsirIndex";
  const TafsirIndexScreen({super.key});

  @override
  State<TafsirIndexScreen> createState() => _TafsirIndexScreenState();
}

class _TafsirIndexScreenState extends State<TafsirIndexScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _surahs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      dynamic data = await _apiService.getSurahsList();
      List<dynamic> list = [];
      
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data.containsKey('value')) {
          list = data['value'];
        } else if (data.containsKey('surahs')) {
          list = data['surahs'];
        }
      }

      if (mounted) {
        setState(() {
          _surahs = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Tafsir Index Error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
          title: const Text("فهرس التفسير", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow)),
          centerTitle: true,
          actions: [_ThemeToggle()],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.yellow))
            : ListView.separated(
                padding: const EdgeInsets.all(15),
                itemCount: 114, // دائماً 114 لضمان ظهور القائمة
                separatorBuilder: (context, index) => Divider(
                  color: AppColors.yellow.withValues(alpha: 0.3),
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final bool hasApiData = _surahs.isNotEmpty && index < _surahs.length;
                  final dynamic surahData = hasApiData ? _surahs[index] : null;

                  final String name = surahData?['name_ar'] ?? SuraName.listSuraName[index];
                  final int surahNumber = int.tryParse(surahData?['number']?.toString() ?? '') ?? (index + 1);
                  final String ayahs = surahData?['ayat_count']?.toString() ?? "---";
                  final String type = surahData?['type'] == 'Meccan' ? 'مكية' : 'مدنية';

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    leading: CircleAvatar(
                      backgroundColor: AppColors.yellow,
                      child: Text(
                        "$surahNumber",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      name,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: provider.isDarkMode() ? Colors.white : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      "$type - آياتها: $ayahs",
                      style: TextStyle(
                        fontSize: 14,
                        color: provider.isDarkMode() ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.yellow, size: 18),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        TafsirDetailsScreen.routeName,
                        arguments: {
                          'number': surahNumber,
                          'name': name,
                        },
                      );
                    },
                  );
                },
              ),
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
