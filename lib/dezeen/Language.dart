import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';

class onClickLanguageWidgit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Language",
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
        colorLanguage(true, "English"),
        SizedBox(
          height: 10,
        ),
        colorLanguage(false, "العربيه"),
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
