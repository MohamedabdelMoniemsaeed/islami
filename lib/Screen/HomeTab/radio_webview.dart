import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RadioWebView extends StatefulWidget {
  const RadioWebView({super.key});

  @override
  State<RadioWebView> createState() => _RadioWebViewState();
}

class _RadioWebViewState extends State<RadioWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress < 100 && mounted) {
              setState(() => _isLoading = true);
            }
          },
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (mounted) {
              setState(() => _error = error.description);
              _isLoading = false;
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://www.mp3quran.net/ar/radio'));
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    bool isDark = provider.isDarkMode();

    return Scaffold(
      backgroundColor: isDark ? AppColors.yellowDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.yellow, size: 26),
          tooltip: "رجوع",
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          "إذاعات القرآن الكريم",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.yellow),
        ),
        centerTitle: true,
        actions: [const _ThemeToggle()],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: isDark ? AppColors.yellowDark.withOpacity(0.8) : Colors.white.withOpacity(0.8),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.yellow),
              ),
            ),
          if (_error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() { _error = null; _isLoading = true; });
                      _controller.loadRequest(Uri.parse('https://www.mp3quran.net/ar/radio'));
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة المحاولة"),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.yellow),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final isDark = provider.isDarkMode();
    return ThemeSwitcher(
      builder: (ctx) => SizedBox(
        width: 48, height: 48,
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
