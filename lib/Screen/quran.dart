import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/colors.dart';
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
      if (arguments.content != null && arguments.content!.isNotEmpty) {
        content = arguments.content!;
      } else {
        readFile(arguments);
      }
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
            arguments.suraName, // عرض اسم السورة بدلاً من "إسلامي"
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
                      // تمت إزالة اسم السورة من هنا لأنه انتقل للـ AppBar
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
    try {
      String fileContent = await rootBundle.loadString(
        arguments.isQuranfile
            ? "assets/quran/${arguments.fileName}"
            : "assets/ahadeth/${arguments.fileName}"
      );

      if (arguments.isQuranfile) {
        // إضافة البسملة في بداية السورة (باستثناء الفاتحة والتوبة إذا كان الملف لا يحتويها)
        // عادة في هذه الملفات، السورة تبدأ من الآية الأولى مباشرة
        String bismillah = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ\n";
        
        List<String> fileLines = fileContent.trim().split("\n");
        for (int i = 0; i < fileLines.length; i++) {
          fileLines[i] += " (${_toArabicNumbers((i + 1).toString())}) ";
        }
        
        // لا نضيف البسملة إذا كانت السورة هي الفاتحة أو التوبة (أو حسب رغبتك)
        // الفاتحة هي 1.txt، التوبة هي 9.txt
        if (arguments.fileName != "1.txt" && arguments.fileName != "9.txt") {
          content = bismillah + fileLines.join();
        } else {
          content = fileLines.join();
        }
      } else {
        content = fileContent;
      }
      
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          content = "خطأ في تحميل المحتوى";
        });
      }
    }
  }

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }
}
