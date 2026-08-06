import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/splash_screen.dart';
import 'package:islami/Screen/HomeTab/surah_index_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_details_screen.dart';
import 'package:islami/Screen/HomeTab/tafsir_index_screen.dart';
import 'package:islami/Screen/HomeTab/laylat_al_qadr_screen.dart';
import 'package:islami/Screen/HomeTab/reciter_audio_screen.dart';
import 'package:islami/Screen/HomeTab/azkar_screen.dart';
import 'package:islami/Screen/HomeTab/duas_screen.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/connectivity_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. تهيئة مشغل الصوت في الخلفية أولاً
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.islami.audio',
    androidNotificationChannelName: 'Radio Playback',
    androidNotificationOngoing: true,
  );

  // 2. تهيئة الإشعارات
  await NotificationService().init();
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  late StreamSubscription<List<ConnectivityResult>> _subscription;
  bool _isFirstLoad = true;
  bool _wasConnected = true;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _subscription = ConnectivityService().connectivityStream.listen((results) {
      bool isNowConnected = results.any((r) => r != ConnectivityResult.none);
      
      if (_isFirstLoad) {
        _wasConnected = isNowConnected;
        _isFirstLoad = false;
        return;
      }

      if (isNowConnected && !_wasConnected) {
        _showConnectivitySnackBar(true);
      } else if (!isNowConnected && _wasConnected) {
        _showConnectivitySnackBar(false);
      }
      
      _wasConnected = isNowConnected;
    });
  }

  Future<void> _requestPermissions() async {
    try {
      await Permission.notification.request();
      await Permission.scheduleExactAlarm.request();
    } catch (e) {
      debugPrint("Permission error: $e");
    }
  }

  void _showConnectivitySnackBar(bool isConnected) {
    final context = messengerKey.currentContext;
    if (context == null) return;

    final localizations = AppLocalizations.of(context)!;
    final message = isConnected 
        ? localizations.internetConnected 
        : localizations.internetDisconnected;
    
    messengerKey.currentState?.hideCurrentSnackBar();
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    
    return MaterialApp(
      scaffoldMessengerKey: messengerKey,
      title: 'Islami App',
      debugShowCheckedModeBanner: false,
      themeMode: provider.mode,
      theme: Apptheme.lightTheme,
      darkTheme: Apptheme.darkTheme,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar'),
      ],
      locale: const Locale('ar'),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        SplashScreen.routeName: (_) => const SplashScreen(),
        SurahIndexScreen.routeName: (_) => const SurahIndexScreen(),
        TafsirIndexScreen.routeName: (_) => const TafsirIndexScreen(),
        TafsirDetailsScreen.routeName: (_) => const TafsirDetailsScreen(surahNumber: 1, surahName: ""),
        LaylatAlQadrScreen.routeName: (_) => const LaylatAlQadrScreen(),
        ReciterAudioScreen.routeName: (_) => const ReciterAudioScreen(reciterId: 112),
        AzkarScreen.routeName: (_) => const AzkarScreen(),
        DuasScreen.routeName: (_) => const DuasScreen(),
      },
      initialRoute: SplashScreen.routeName,
    );
  }
}
