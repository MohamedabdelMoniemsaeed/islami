import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';
import 'package:islami/Screen/HomeTab/laylat_al_qadr_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/dezeen/surah_pages.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  final PageController _pageController = PageController(initialPage: 0);
  final ApiService _apiService = ApiService();
  List<dynamic> _surahs = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadSurahs();
  }

  Future<void> _loadSurahs() async {
    try {
      final dynamic data = await _apiService.getSurahsList();
      List<dynamic> list = [];
      if (data is List) {
        list = data;
      } else if (data is Map) {
        if (data.containsKey('value')) {
          list = data['value'];
        } else if (data.containsKey('surahs')) {
          list = data['surahs'];
        } else if (data.containsKey('data')) {
          list = data['data'];
        }
      }
      if (mounted) {
        setState(() {
          _surahs = list;
        });
      }
    } catch (e) {
      debugPrint("Error loading surahs in QuranTab: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      // إزالة الـ AppBar لجعل الصورة تبدأ من أعلى الشاشة
      drawer: Drawer(
        child: Container(
          color: provider.isDarkMode() ? AppColors.yellowDark : Colors.white,
          child: Column(
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                    color: provider.isDarkMode()
                        ? AppColors.yellowDark
                        : AppColors.yellow),
                child: Center(
                    child: Image.asset('assets/images/quran.png', height: 80)),
              ),
              // خيارات القائمة
              _buildDrawerItem(Icons.menu_book, "فهرس السور", () async {
                Navigator.pop(context); // إغلاق القائمة الجانبية
                final selectedPage = await Navigator.pushNamed(
                    context, SurahIndexScreen.routeName);
                if (selectedPage != null && selectedPage is int) {
                  _pageController.jumpToPage(selectedPage - 1);
                }
              }, provider.isDarkMode()),
              const Divider(),
              _buildDrawerItem(
                  Icons.translate,
                  "تفسير الصفحة الحالية",
                  () {
                    Navigator.pop(context);
                    _showCurrentPageTafsir(provider.isDarkMode());
                  },
                  provider.isDarkMode()),
              const Divider(),
              _buildDrawerItem(
                  Icons.list_alt,
                  "فهرس التفسير (كل السور)",
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, TafsirIndexScreen.routeName);
                  },
                  provider.isDarkMode()),
              const Divider(),
              _buildDrawerItem(
                  Icons.nightlight_round,
                  "ليلة القدر",
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, LaylatAlQadrScreen.routeName);
                  },
                  provider.isDarkMode()),
              const Divider(),
              _buildDrawerItem(
                  Icons.person,
                  "الشيخ محمد صديق المنشاوي",
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, ReciterAudioScreen.routeName, arguments: {'reciter_id': 112});
                  },
                  provider.isDarkMode()),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context)
                .openDrawer(), // فتح القائمة عند الضغط على الصورة
            child: PageView.builder(
              controller: _pageController,
              reverse: false, // السحب من اليسار لليمين كما طلبت
              itemCount: 603,
              onPageChanged: (page) => setState(() => _currentPage = page),
              itemBuilder: (context, index) {
                final pageNumber = (index + 1).toString().padLeft(3, '0');
                return InteractiveViewer(
                  child: Image.asset(
                    'assets/images/quran/$pageNumber.png',
                    fit: BoxFit.fill,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
            ),
          ),
          // وضع زر القائمة فوق الصورة في الأعلى
          Positioned(
            top: 20,
            right: 15,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppColors.yellow, size: 35),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ],
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

  void _goToPage(int page) {
    _pageController.jumpToPage(page - 1);
    Navigator.pop(context);
  }

  void _showCurrentPageTafsir(bool isDark) {
    // تحديد السورة الحالية بناءً على الصفحة
    int currentSuraNum = 1;
    String currentSuraName = "الفاتحة";

    if (_surahs.isNotEmpty) {
      for (var surah in _surahs) {
        try {
          int surahNum = int.parse(surah['number'].toString());
          int surahPage = SurahPages.startPages[surahNum - 1];
          if (surahPage <= (_currentPage + 1)) {
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

  void _showLaylatAlQadrDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.yellow)),
    );

    try {
      final data = await _apiService.getLaylatAlQadr();
      Navigator.pop(context); // Close loading

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text("فضل ليلة القدر",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.yellow)),
                ),
                const SizedBox(height: 20),
                Text(data['content'] ?? data['description'] ?? "لا توجد تفاصيل حالياً",
                    style: const TextStyle(fontSize: 18, height: 1.6)),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ في تحميل البيانات")));
    }
  }

  void _showAudioDialog(String title, int reciterId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: AppColors.yellow)),
    );

    try {
      final List<dynamic> tracks = await _apiService.getReciterAudio(reciterId);
      Navigator.pop(context);

      final AudioPlayer audioPlayer = AudioPlayer();

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.yellow)),
              const Divider(),
              Expanded(
                child: tracks.isEmpty
                    ? const Center(child: Text("لا توجد ملفات صوتية متاحة"))
                    : ListView.separated(
                        itemCount: tracks.length,
                        separatorBuilder: (c, i) => const Divider(),
                        itemBuilder: (context, index) {
                          final track = tracks[index];
                          return ListTile(
                            leading: const Icon(Icons.play_circle_fill, color: AppColors.yellow, size: 30),
                            title: Text(track['name'] ?? "تلاوة ${index + 1}", style: const TextStyle(fontSize: 18)),
                            onTap: () async {
                              await audioPlayer.play(UrlSource(track['url']));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("جاري تشغيل: ${track['name']}"), duration: const Duration(seconds: 2)),
                              );
                            },
                          );
                        },
                      ),
              ),
              ElevatedButton(
                onPressed: () {
                  audioPlayer.stop();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
                child: const Text("إيقاف الصوت وإغلاق", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("حدث خطأ في تحميل الصوتيات")));
    }
  }
}
