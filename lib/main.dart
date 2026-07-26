import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:islami/dezeen/connectivity_service.dart';
import 'package:islami/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    await Permission.notification.request();
    await Permission.scheduleExactAlarm.request();
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
        QuranScreen.routeName: (_) => const QuranScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
