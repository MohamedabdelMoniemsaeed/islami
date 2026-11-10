import 'dart:async';
import 'dart:ui';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/destinations_screen.dart';
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
import 'package:islami/services/api_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Handle all Flutter errors
    FlutterError.onError = (details) {
      debugPrint("FlutterError: ${details.exception}");
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint("PlatformDispatcherError: $error");
      return true;
    };

    try {
      // 1. Background Audio Init
      await JustAudioBackground.init(
        androidNotificationChannelId: 'com.example.islami.audio',
        androidNotificationChannelName: 'مشغل الصوت',
        androidNotificationOngoing: true,
        androidResumeOnClick: true,
        notificationColor: const Color(0xFFF5A623),
      );

      // 2. Notifications Init
      await NotificationService().init();

      // 3. Schedule Prayers
      ApiService().getPrayerTimes().then((t) =>
          NotificationService().scheduleEnabledPrayers(t)).catchError((e) {
        debugPrint("Prayer scheduling error: $e");
      });

      // 4. Shorebird Auto Update (wrapped in try-catch)
      try {
        await _autoUpdate();
      } catch (e) {
        debugPrint("Shorebird update failed: $e");
      }

    } catch (e, stack) {
      debugPrint("Initialization error: $e\\n$stack");
    }

    // Load persisted theme before building the app
    final themeProvider = AppProvider();
    await themeProvider.loadTheme();

    runApp(
      ChangeNotifierProvider<AppProvider>(
        create: (_) => themeProvider,
        child: const MyApp(),
      ),
    );
  }, (error, stack) {
    debugPrint("ZonedGuarded Error: $error\\n$stack");
  });
}

Future<void> _autoUpdate() async {
  final updater = ShorebirdUpdater();
  if (!updater.isAvailable) return;
  final status = await updater.checkForUpdate();
  if (status == UpdateStatus.outdated) {
    await updater.update();
  }
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

    return ThemeProvider(
      initTheme:
          provider.mode == ThemeMode.dark ? Apptheme.darkTheme : Apptheme.lightTheme,
      builder: (context, myTheme) {
        final appRoutes = {
          DestinationsScreen.routeName: (_) => const DestinationsScreen(),
          SplashScreen.routeName: (_) => const SplashScreen(),
          SurahIndexScreen.routeName: (_) => const SurahIndexScreen(),
          TafsirIndexScreen.routeName: (_) => const TafsirIndexScreen(),
          TafsirDetailsScreen.routeName: (_) =>
              const TafsirDetailsScreen(surahNumber: 1, surahName: ""),
          LaylatAlQadrScreen.routeName: (_) => const LaylatAlQadrScreen(),
          ReciterAudioScreen.routeName: (_) =>
              const ReciterAudioScreen(reciterId: 112),
          AzkarScreen.routeName: (_) => const AzkarScreen(),
          DuasScreen.routeName: (_) => const DuasScreen(),
        };

        return MaterialApp(
          navigatorKey: navigatorKey,
          scaffoldMessengerKey: messengerKey,
          title: 'Islami App',
          debugShowCheckedModeBanner: false,
          theme: myTheme,
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
          routes: appRoutes,
          initialRoute: SplashScreen.routeName,
          onGenerateRoute: (settings) {
            if (settings.name == HomeScreen.routeName) {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => HomeScreen(startTab: settings.arguments as int? ?? 0),
              );
            }
            final factory = appRoutes[settings.name];
            return factory == null
                ? null
                : MaterialPageRoute(
                    settings: settings,
                    builder: (_) => factory(context),
                  );
          },
        );
      },
    );
  }
}
