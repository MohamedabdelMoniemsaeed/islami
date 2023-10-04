import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';

abstract class Apptheme {
  static ThemeData lightTheme = ThemeData(
      primaryColor: AppColors.yellow,
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.transparent,
        centerTitle: true,
        titleTextStyle: TextStyle(
            fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.black),
      ),
      badgeTheme: const BadgeThemeData(
        // AhadethName, SuraName , عدد التسبيحات , عدد التسبيح,
        textStyle: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: AppColors.black,
        ),

        alignment: Alignment.center,
      ),
      textTheme: const TextTheme(
        //Language , Mode
        bodyLarge: TextStyle(
            color: AppColors.black, fontSize: 24, fontWeight: FontWeight.bold),
        // الحمد لله ,
        displayLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        //الحديث رقم , سوره ,
        displayMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            color: AppColors.black),
        // English , dark
        displaySmall: TextStyle(
            color: AppColors.yellow, fontSize: 16, fontWeight: FontWeight.bold),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.black,
        showSelectedLabels: false,
        unselectedIconTheme: IconThemeData(size: 30),
        selectedIconTheme: IconThemeData(
          size: 36,
        ),
        
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          color: AppColors.black,
        ),
      ),
      
      canvasColor: AppColors.yellow,
      );
      // primaryColorLight: AppColors.black);

  static ThemeData darkTheme = ThemeData(
    primaryColor: AppColors.yellowDark,
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.transparent,
      centerTitle: true,
      // Islami
      titleTextStyle: TextStyle(
          fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.black),
    ),
    badgeTheme: const BadgeThemeData(
      // AhadethName, SuraName , عدد التسبيحات , عدد التسبيح,
      textStyle: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),

      alignment: Alignment.center,
    ),
    textTheme: const TextTheme(
      //Language , Mode
      bodyLarge: TextStyle(
          color: AppColors.white, fontSize: 24, fontWeight: FontWeight.bold),
      // الحمد لله ,
      displayLarge: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.blackDark,
      ),
      //الحديث رقم , سوره ,
      displayMedium: TextStyle(
          fontSize: 24, fontWeight: FontWeight.normal, color: AppColors.white),
      // English , dark
      displaySmall: TextStyle(
          color: AppColors.yellowDark, fontSize: 16, fontWeight: FontWeight.bold),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: AppColors.blackDark,
        showSelectedLabels: false,
        unselectedIconTheme: IconThemeData(size: 30),
        selectedIconTheme: IconThemeData(
          size: 36,
        ),
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          color: AppColors.blackDark,
        ),
      ),
      canvasColor: AppColors.yellowDark,
  );
   
}
