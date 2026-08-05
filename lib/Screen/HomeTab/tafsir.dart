import 'package:flutter/material.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/dezeen/sura_name.dart';
import 'package:provider/provider.dart';

class TafsirTab extends StatelessWidget {
  const TafsirTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final ApiService apiService = ApiService();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "التفسير الميسر",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: AppColors.yellow,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: SuraName.listSuraName.length,
            separatorBuilder: (context, index) =>
                const Divider(color: AppColors.yellow, thickness: 0.5),
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  SuraName.listSuraName[index],
                  style: TextStyle(
                    color: provider.isDarkMode() ? Colors.white : Colors.black,
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                onTap: () => _showTafsirDialog(
                  context,
                  index + 1,
                  SuraName.listSuraName[index],
                  provider.isDarkMode(),
                  apiService,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTafsirDialog(BuildContext context, int suraNumber, String suraName,
      bool isDark, ApiService apiService) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.yellowDark : Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "تفسير سورة $suraName",
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow),
              ),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: FutureBuilder<TafsirResponse>(
                  future: apiService.getTafsir(suraNumber),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.yellow));
                    } else if (snapshot.hasError) {
                      return const Center(child: Text("خطأ في تحميل التفسير"));
                    }
                    final tafsirList = snapshot.data!.result;
                    return ListView.builder(
                      itemCount: tafsirList.length,
                      itemBuilder: (context, index) {
                        final item = tafsirList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text("الآية (${item.aya})",
                                  style: const TextStyle(
                                      color: AppColors.yellow,
                                      fontWeight: FontWeight.bold),
                                  textDirection: TextDirection.rtl),
                              Text(item.arabicText,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                  textDirection: TextDirection.rtl),
                              Text(item.translation,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black54),
                                  textDirection: TextDirection.rtl),
                              const Divider(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
