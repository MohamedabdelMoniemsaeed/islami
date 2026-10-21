import 'package:flutter/material.dart';

class Apptheme {
  static const Color primaryColor = Color(0xFF202020);
  static const Color accentColor = Color(0xFFE2BE7F);
  static const Color darkBackground = Color(0xFF121212);
  static const Color lightBackground = Color(0xFFF8F9FA);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: accentColor,
      centerTitle: true,
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: darkBackground,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      foregroundColor: accentColor,
      centerTitle: true,
    ),
  );
}
