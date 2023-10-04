import 'package:flutter/material.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/suraName.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuranTab extends StatelessWidget {
  const QuranTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Image.asset(AppImage.Quran),
        ),
        Divider(
          color: AppColors.yellow,
          thickness: 2,
        ),
        Text(
          AppLocalizations.of(context)!.suraName,
          textAlign: TextAlign.center,
          style: Theme.of(context).badgeTheme.textStyle,
        ),
        Divider(
          color: AppColors.yellow,
          thickness: 2,
        ),
        Expanded(
          flex: 7,
          child: ListView.builder(
              itemCount: SuraName.listSuraName.length,
              itemBuilder: (_, index) {
                return MaterialButton(
                  splashColor: AppColors.yellow,
                  onPressed: () {
                    Navigator.pushNamed(context, QuranScreen.routeName,
                        arguments: DataQuran(
                            fileName: "${index + 1}.txt",
                            isQuranfile: true,
                            suraName: SuraName.listSuraName[index]));
                  },
                  child: Text(
                    SuraName.listSuraName[index],
                    style: Theme.of(context).textTheme.displayMedium,
                    textAlign: TextAlign.center,
                  ),
                );
              }),
        )
      ],
    );
  }
}
