import 'package:flutter/material.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  late PageController _pageController;
  int _lastProviderPage = -1;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentQuranPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    // التحقق إذا كان هناك طلب انتقال لصفحة جديدة من الفهرس (عبر البروفايدر)
    if (provider.currentQuranPage != _lastProviderPage) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(provider.currentQuranPage);
        _lastProviderPage = provider.currentQuranPage;
      }
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageView.builder(
        controller: _pageController,
        reverse: false,
        itemCount: 603,
        onPageChanged: (page) {
          provider.updateQuranPage(page);
          _lastProviderPage = page;
        },
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
    );
  }
}
