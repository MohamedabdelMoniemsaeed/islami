import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/azkar_model.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class AzkarTab extends StatelessWidget {
  const AzkarTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final ApiService apiService = ApiService();

    return Column(
      children: [
        const SizedBox(height: 20),
        Text(
          AppLocalizations.of(context)!.azkar,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.yellow,
            fontSize: 28,
          ),
        ),
        const Divider(color: AppColors.yellow, thickness: 2),
        Expanded(
          child: FutureBuilder<AzkarResponse>(
            future: apiService.getAzkar(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.yellow));
              } else if (snapshot.hasError) {
                return const Center(child: Text("خطأ في تحميل الأذكار"));
              }

              final categories = snapshot.data!.categories;

              return ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) => const Divider(color: AppColors.yellow, thickness: 1),
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () {
                      _showAzkarList(context, categories[index], provider.isDarkMode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        categories[index].categoryName,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: provider.isDarkMode() ? Colors.white : Colors.black,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAzkarList(BuildContext context, AzkarCategory category, bool isDark) {
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
                category.categoryName,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.yellow),
              ),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: ListView.builder(
                  itemCount: category.azkar.length,
                  itemBuilder: (context, index) {
                    final item = category.azkar[index];
                    return Card(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              item.zekr,
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(height: 10),
                            if (item.description.isNotEmpty)
                              Text(
                                item.description,
                                style: const TextStyle(fontSize: 14, color: AppColors.yellow),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            const SizedBox(height: 10),
                            CircleAvatar(
                              backgroundColor: AppColors.yellow,
                              radius: 15,
                              child: Text(
                                item.count,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
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
