import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/quran.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp( ChangeNotifierProvider(
    create: (_)=>Shiar(),
    child: MyApp(),),);
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    Shiar providr = Provider.of(context);
    return MaterialApp(
themeMode: providr.mode,
darkTheme: Apptheme.darkTheme,
theme: Apptheme.lightTheme,

       title: 'Localizations Sample App',
  localizationsDelegates: [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    AppLocalizations.delegate,
  ],
  supportedLocales: [
    Locale('en'),//English
    Locale('ar'), // Arabic
  ],
      locale: Locale(providr.lang),
      debugShowCheckedModeBanner: false,
      routes: {
        HomeScreen.routeName: (_) => HomeScreen(),
        QuranScreen.routeName: (_) => QuranScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
