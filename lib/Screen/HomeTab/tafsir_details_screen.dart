import 'package:flutter/material.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/images.dart';
import 'package:provider/provider.dart';

class TafsirDetailsScreen extends StatefulWidget {
  static const String routeName = "TafsirDetails";
  final int surahNumber;
  final String surahName;

  const TafsirDetailsScreen({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<TafsirDetailsScreen> createState() => _TafsirDetailsScreenState();
}

class _TafsirDetailsScreenState extends State<TafsirDetailsScreen> {
  final ApiService _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final dynamic args = ModalRoute.of(context)!.settings.arguments;
    final int surahNumber = args != null ? (args as Map)['number'] : widget.surahNumber;
    final String surahName = args != null ? (args as Map)['name'] : widget.surahName;

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
            provider.isDarkMode() ? AppImage.backgroundDark : AppImage.backgroundHome
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text("تفسير سورة $surahName", 
            style: TextStyle(color: provider.isDarkMode() ? AppColors.blackDark : Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: true,
          iconTheme: IconThemeData(color: provider.isDarkMode() ? AppColors.blackDark : Colors.black),
        ),
        body: FutureBuilder<TafsirResponse>(
          future: _apiService.getTafsir(surahNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
            }
            if (snapshot.hasError) {
              return const Center(child: Text("خطأ في تحميل التفسير، تأكد من الإنترنت"));
            }
            if (!snapshot.hasData || snapshot.data!.result.isEmpty) {
              return const Center(child: Text("لا توجد بيانات لهذا التفسير"));
            }

            final tafsirList = snapshot.data!.result;
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tafsirList.length,
              itemBuilder: (context, index) {
                final item = tafsirList[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: provider.isDarkMode() ? Colors.black.withOpacity(0.6) : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: AppColors.yellow.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.yellow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "الآية ${item.aya}",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.arabicText,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: provider.isDarkMode() ? AppColors.blackDark : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      const Divider(height: 30, color: AppColors.yellow),
                      Text(
                        item.translation,
                        style: TextStyle(
                          fontSize: 19,
                          height: 1.6,
                          color: provider.isDarkMode() ? Colors.white : Colors.black87,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
