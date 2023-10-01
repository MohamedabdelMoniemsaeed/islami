import 'package:flutter/material.dart';
import 'package:islami/Screen/home.dart';
import 'package:islami/Screen/quran.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        HomeScreen.routeName: (_) => HomeScreen(),
        QuranScreen.routeName: (_) => QuranScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
