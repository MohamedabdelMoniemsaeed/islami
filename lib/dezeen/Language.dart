import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';
class onClickLanguageWidgit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Shiar providr = Provider.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocalizations.of(context)!.language,
          style: TextStyle(fontSize: 19),
          textAlign: TextAlign.center,
        ),
        Divider(
          color: AppColors.yellow,
          endIndent: 100,
          indent: 100,
        ),
        SizedBox(
          height: 30,
        ),
        InkWell(
          onTap: (){
            providr.lang = "en";
            providr.notifyListeners();
            Navigator.pop(context);
          },
          child:colorLanguage(providr.lang =="en", "English"),
        ),

        SizedBox(
          height: 10,
        ),
        InkWell(
          onTap:(){
            providr.lang = "ar";
            providr.notifyListeners();
            Navigator.pop(context);
          },
         child: colorLanguage(providr.lang =="ar", "العربيه"),
        )

      ],
    );
  }

  colorLanguage(bool onclick, String language) {
    if (onclick) {
      return Text(
        language,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: AppColors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        language,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: AppColors.black, fontSize: 20, fontWeight: FontWeight.bold),
      );
    }
  }
}
