import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/sura_name.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/tafsir_model.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class TafasirTab extends StatelessWidget {
  const TafasirTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.tafasir,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.yellow,
            fontSize: 28,
          ),
        ),
        const Divider(color: AppColors.yellow, thickness: 2),
        Expanded(
          child: ListView.separated(
            itemCount: SuraName.listSuraName.length,
            separatorBuilder: (context, index) => const Divider(color: AppColors.yellow, thickness: 1),
            itemBuilder: (context, index) {
              return MaterialButton(
                onPressed: () {
                  _showTafsirDialog(context, index + 1, SuraName.listSuraName[index], provider.isDarkMode());
                },
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    SuraName.listSuraName[index],
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: provider.isDarkMode() ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showTafsirDialog(BuildContext context, int suraNumber, String suraName, bool isDark) {
    final ApiService apiService = ApiService();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.yellowDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                "تفسير سورة $suraName",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: FutureBuilder<TafsirResponse>(
                  future: apiService.getTafsir(suraNumber),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
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
                              Text(
                                "الآية (${item.aya})",
                                style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.bold, fontSize: 18),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.arabicText,
                                style: TextStyle(fontSize: 20, color: isDark ? Colors.white70 : Colors.black87),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.translation,
                                style: TextStyle(fontSize: 18, color: isDark ? Colors.white : Colors.black54),
                                textDirection: TextDirection.rtl,
                              ),
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
