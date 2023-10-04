import 'package:flutter/material.dart';
import 'package:islami/Screen/HomeTab/Sebha.dart';
import 'package:islami/Screen/HomeTab/ahadeth.dart';
import 'package:islami/Screen/HomeTab/quran.dart';
import 'package:islami/Screen/HomeTab/radio.dart';
import 'package:islami/Screen/HomeTab/settings.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  static const String routeName = "Home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int cindex = 0;
  List<Widget> tabs = [
    QuranTab(),
    AhadethTab(),
    SebhaTab(),
    RadioTab(),
    SettingsTap(),
  ];

  @override
  Widget build(BuildContext context) {
    Shiar provider = Provider.of(context);
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(provider.mode == ThemeMode.light? AppImage.backgroundHome:AppImage.backgroundDark), fit: BoxFit.fill)),
      child: Scaffold(
        appBar: AppBar(
         
          title:  Text(
            AppLocalizations.of(context)!.islami,
            style: Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: tabs[cindex],
        
        bottomNavigationBar: buildBottomNavigationBar(),
      ),
    );
  }

  Widget buildBottomNavigationBar() => Theme(
        data: ThemeData(canvasColor: AppColors.yellow),
        child: BottomNavigationBar(
          selectedItemColor:Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          iconSize: 30,
          
          currentIndex: cindex,
          onTap: (index) {
            cindex = index;

            setState(() {});
          },
          items:  [
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(AppImage.icQuran)), label:  AppLocalizations.of(context)!.quran),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(AppImage.icAhadeth)),
                label: AppLocalizations.of(context)!.ahadeth),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(AppImage.icsebha)), label: AppLocalizations.of(context)!.sebha,),
            BottomNavigationBarItem(
                icon: ImageIcon(AssetImage(AppImage.icRadio)), label: AppLocalizations.of(context)!.radio),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: AppLocalizations.of(context)!.settings),
          ],
        ),
      );
}
