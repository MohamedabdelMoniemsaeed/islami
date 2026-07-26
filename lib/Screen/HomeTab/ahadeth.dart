import 'package:flutter/material.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/hadith_model.dart';
import 'package:provider/provider.dart';

class AhadethTab extends StatefulWidget {
  const AhadethTab({super.key});

  @override
  State<AhadethTab> createState() => _AhadethTabState();
}

class _AhadethTabState extends State<AhadethTab> {
  final ApiService _apiService = ApiService();
  int _currentBookIndex = 0;
  int _currentPage = 1;
  
  void _nextBook() {
    setState(() {
      _currentBookIndex = (_currentBookIndex + 1) % ApiService.hadithBooks.length;
      _currentPage = 1;
    });
  }

  void _previousBook() {
    setState(() {
      _currentBookIndex = (_currentBookIndex - 1 + ApiService.hadithBooks.length) % ApiService.hadithBooks.length;
      _currentPage = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var provider = Provider.of<AppProvider>(context);
    String bookId = ApiService.hadithBooks[_currentBookIndex]['id']!;
    String bookName = ApiService.hadithBooks[_currentBookIndex]['name']!;

    return Column(
      children: [
        // الجزء العلوي الثابت مع الأسهم لتغيير الكتاب
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: provider.isDarkMode() ? AppColors.yellowDark : const Color(0xFFF8F8F8),
            border: const Border(bottom: BorderSide(color: AppColors.yellow, width: 2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _previousBook,
                icon: const Icon(Icons.arrow_back_ios, color: AppColors.yellow),
              ),
              Column(
                children: [
                  Text(
                    bookName,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 24,
                      color: provider.isDarkMode() ? Colors.white : Colors.black,
                    ),
                  ),
                  Text(
                    "صفحة ${_toArabicNumbers(_currentPage.toString())}",
                    style: const TextStyle(color: AppColors.yellow, fontSize: 16),
                  ),
                ],
              ),
              IconButton(
                onPressed: _nextBook,
                icon: const Icon(Icons.arrow_forward_ios, color: AppColors.yellow),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: FutureBuilder<HadithResponse>(
            key: ValueKey("$bookId-$_currentPage"), // لضمان التحديث عند تغيير الكتاب
            future: _apiService.getHadiths(bookId, _currentPage),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "تعذر الاتصال بالخادم. تأكد من الإنترنت.",
                    style: TextStyle(color: provider.isDarkMode() ? Colors.white : Colors.black),
                  ),
                );
              }

              final hadiths = snapshot.data!.items;

              return ListView.separated(
                itemCount: hadiths.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.yellow, thickness: 1),
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        QuranScreen.routeName,
                        arguments: DataQuran(
                          fileName: "api_hadith_${hadiths[index].number}",
                          isQuranfile: false,
                          suraName: "$bookName - حديث ${_toArabicNumbers(hadiths[index].number.toString())}",
                          content: hadiths[index].arab,
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      child: Text(
                        "حديث رقم ${_toArabicNumbers(hadiths[index].number.toString())}",
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        
        // أزرار التنقل بين الصفحات
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          color: provider.isDarkMode() ? AppColors.yellowDark : Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_currentPage > 1)
                TextButton(
                  onPressed: () => setState(() => _currentPage--),
                  child: const Text("السابق", style: TextStyle(color: AppColors.yellow)),
                ),
              const SizedBox(width: 20),
              TextButton(
                onPressed: () => setState(() => _currentPage++),
                child: const Text("المزيد من الأحاديث", style: TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ],
    );
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
