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
import 'package:islami/services/notification_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await NotificationService().init();
  } catch (_) {}
  
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    
    return MaterialApp(
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
