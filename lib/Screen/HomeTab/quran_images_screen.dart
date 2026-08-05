import 'package:flutter/material.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class QuranImagesScreen extends StatefulWidget {
  static const String routeName = "QuranImages";

  const QuranImagesScreen({super.key});

  @override
  State<QuranImagesScreen> createState() => _QuranImagesScreenState();
}

class _QuranImagesScreenState extends State<QuranImagesScreen> {
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
    final list = await _apiService.getSurahsList();
    setState(() {
      _surahs = list;
    });
  }

  void _goToPage(int page) {
    _pageController.jumpToPage(page - 1);
    Navigator.pop(context); // Close drawer
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("المصحف الشريف"),
        centerTitle: true,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: AppColors.yellow),
              child: Center(
                child: Text(
                  "فهرس السور",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 28, color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: _surahs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.separated(
                      itemCount: _surahs.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final surah = _surahs[index];
                        return ListTile(
                          title: Text(
                            surah['name'],
                            style: TextStyle(
                              fontSize: 20,
                              color: provider.isDarkMode() ? Colors.white : Colors.black,
                            ),
                          ),
                          trailing: Text("صفحة ${surah['page']}"),
                          onTap: () => _goToPage(int.parse(surah['page'].toString())),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        reverse: true, // For Right-to-Left (Arabic)
        itemCount: 604,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        itemBuilder: (context, index) {
          final pageNumber = (index + 1).toString().padLeft(3, '0');
          return InteractiveViewer(
            child: Image.asset(
              'assets/images/quran/$pageNumber.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Text("صفحة $pageNumber غير موجودة"),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        color: AppColors.yellow.withOpacity(0.2),
        child: Text(
          "صفحة: ${_currentPage + 1}",
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
