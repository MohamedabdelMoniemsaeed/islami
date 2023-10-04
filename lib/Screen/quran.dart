import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QuranScreen extends StatefulWidget {
  static const String routeName = "Quran";

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late DataQuran arguments;
  String files = '';
  @override
  Widget build(BuildContext context) {
    arguments = ModalRoute.of(context)!.settings.arguments as DataQuran;
    if (files.isEmpty) {
      readFile();
    }
    print(" test1 : ${arguments.fileName}");
    print(" test2 : ${arguments.suraName}");

    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AppImage.backgroundHome), fit: BoxFit.fill)),
      child: Scaffold(
        appBar: AppBar(
          
          title:  Text(
            AppLocalizations.of(context)!.islami,
            style:Theme.of(context).appBarTheme.titleTextStyle,
          ),
        ),
        body: files.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        arguments.suraName,
                        style: Theme.of(context).badgeTheme.textStyle,
                        textAlign: TextAlign.center
                      ),
                      Text(
                        files,
                        style: Theme.of(context).badgeTheme.textStyle,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ),
              ),
        backgroundColor: AppColors.transparent,
      ),
    );
  }

  void readFile() async {
    String futurefile;
    files = await rootBundle.loadString(arguments.isQuranfile
        ? "assets/quran/${arguments.fileName}"
        : "assets/ahadeth/${arguments.fileName}");
    if (!arguments.isQuranfile) {
      setState(() {});
      return;
    }
    List<String> fileLines = files.split("\n");
    for (int i = 0; i < fileLines.length; i++) {
      fileLines[i] += arguments.isQuranfile ? "(${i + 1})" : " ";
    }
    files = fileLines.join();
    setState(() {});
  }
}
