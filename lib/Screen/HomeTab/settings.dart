import 'package:flutter/material.dart';
import 'package:islami/dezeen/Language.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../dezeen/shiar.dart';

class SettingsTap extends StatefulWidget {
  const SettingsTap({super.key});

  @override
  State<SettingsTap> createState() => _SettingsTapState();
}

class _SettingsTapState extends State<SettingsTap> {
  @override
  Widget build(BuildContext context) {
    Shiar providr = Provider.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      SizedBox(
        height: 60,
      ),
      textTitle(AppLocalizations.of(context)!.language),
      SizedBox(
        height: 30,
      ),
      InkWell(
          onTap: () {
            onClickLanguage();
          },
          child: RowTab(providr.lang == "en"?"English":"العربيه")),
      SizedBox(
        height: 50,
      ),
      textTitle(AppLocalizations.of(context)!.mode),
      SizedBox(
        height: 30,
      ),
      InkWell(onTap: () {}, child: RowTab(AppLocalizations.of(context)!.dark)),
    ]);
  }

  Widget textTitle(String name) {
    return Container(
      margin: EdgeInsets.only(
        left: 30,right: 30
      ),
      child: Text(
        name,
        style: Mytheme.quranTitleStyle,
      ),
    );
  }

  Widget RowTab(String name) {
    return Container(
      margin: EdgeInsets.only(left: 40, right: 40),
      height: 50,
      decoration: BoxDecoration(
          color: AppColors.white, border: Border.all(color: AppColors.yellow)),
      child: Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 20),
              child: Text(name,
                  style: TextStyle(
                      color: AppColors.yellow,
                      fontSize: 16,
                      fontWeight: FontWeight.bold))),
          Spacer(),
          Container(
              margin: EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_drop_down)),
        ],
      ),
    );
  }

  void onClickLanguage() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return onClickLanguageWidgit();
        });
  }
}
