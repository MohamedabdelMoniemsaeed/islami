import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class QuranTab extends StatefulWidget {
  const QuranTab({super.key});

  @override
  State<QuranTab> createState() => _QuranTabState();
}

class _QuranTabState extends State<QuranTab> {
  late PageController _pageController;
  int _lastJumpRequest = 0;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    _pageController = PageController(initialPage: provider.currentQuranPage);
    _lastJumpRequest = provider.jumpRequests;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    // التحقق من وجود طلب انتقال جديد (حتى لو لنفس الصفحة)
    if (provider.jumpRequests > _lastJumpRequest) {
      if (_pageController.hasClients) {
        // استخدام Future.microtask لضمان أن القفزة تحدث بعد بناء الواجهة
        Future.microtask(() {
          _pageController.jumpToPage(provider.currentQuranPage);
        });
        _lastJumpRequest = provider.jumpRequests;
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
        },
        itemBuilder: (context, index) {
          final pageNumber = (index + 1).toString().padLeft(3, '0');
          return Stack(
            children: [
              InteractiveViewer(
                child: Image.asset(
                  'assets/images/quran/$pageNumber.png',
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              // علامة الشريط (Bookmark Ribbon) تظهر فقط في الصفحة المحفوظة الحالية
              if (provider.bookmarkedPage == index)
                Positioned(
                  top: 0,
                  left: 20,
                  child: Container(
                    width: 40,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.yellow.withValues(alpha: 0.9),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(Icons.bookmark, color: Colors.white, size: 28),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
