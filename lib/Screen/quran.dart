import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class QuranScreen extends StatefulWidget {
  static const String routeName = "Quran";

  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  String content = '';
  
  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    var arguments = ModalRoute.of(context)!.settings.arguments as DataQuran;
    
    if (content.isEmpty) {
      readFile(arguments);
    }

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() 
                ? AppImage.backgroundDark 
                : AppImage.backgroundHome
          ),
          fit: BoxFit.fill,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.islami,
          ),
        ),
        body: content.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        arguments.suraName,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: provider.isDarkMode() ? AppColors.blackDark : AppColors.yellow,
                          fontSize: 32,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Divider(
                        thickness: 1.5,
                        color: provider.isDarkMode() ? AppColors.blackDark : AppColors.yellow,
                        indent: 40,
                        endIndent: 40,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        content,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: provider.isDarkMode() ? Colors.white : Colors.black,
                          height: 1.8,
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  void readFile(DataQuran arguments) async {
    String fileContent = await rootBundle.loadString(
      arguments.isQuranfile
          ? "assets/quran/${arguments.fileName}"
          : "assets/ahadeth/${arguments.fileName}"
    );

    if (arguments.isQuranfile) {
      List<String> fileLines = fileContent.trim().split("\n");
      for (int i = 0; i < fileLines.length; i++) {
        fileLines[i] += " (${i + 1}) ";
      }
      content = fileLines.join();
    } else {
      content = fileContent;
    }
    
    if (mounted) {
      setState(() {});
    }
  }
}
