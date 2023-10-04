import 'package:flutter/material.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AhadethTab extends StatelessWidget {
  List<String> ahadethName = List.generate(50, (index) {
    return "الحديث رقم ${index + 1}";
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: Image.asset(AppImage.psmallh),
        ),
        Divider(
          color: AppColors.yellow,
          thickness: 2,
        ),
        Text(
          AppLocalizations.of(context)!.ahadethName,
          textAlign: TextAlign.center,
          style: Theme.of(context).badgeTheme.textStyle,
        ),
        Divider(
          color: AppColors.yellow,
          thickness: 2,
        ),
        Expanded(
          flex: 7,
          child: ListView.builder(itemBuilder: (_, index) {
            return MaterialButton(
              splashColor: AppColors.yellow,
              onPressed: () {
                Navigator.pushNamed(context, QuranScreen.routeName,
                    arguments: DataQuran(
                        fileName: "h${index + 1}.txt",
                        isQuranfile: false,
                        suraName: ahadethName[index]));
              },
              child: Text(
                ahadethName[index],
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
