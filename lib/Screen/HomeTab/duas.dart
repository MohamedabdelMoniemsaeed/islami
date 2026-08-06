import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/services/api_service.dart';
import 'package:islami/models/duas_model.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:provider/provider.dart';

class DuasTab extends StatelessWidget {
  const DuasTab({super.key});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<AppProvider>(context);
    final ApiService apiService = ApiService();

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "الأدعية المستجابة",
          style: TextStyle(
            color: AppColors.yellow,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(color: AppColors.yellow, thickness: 2),
        Expanded(
          child: FutureBuilder<DuasResponse>(
            future: apiService.getDuas(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(color: AppColors.yellow));
              } else if (snapshot.hasError) {
                return const Center(child: Text("خطأ في تحميل الأدعية"));
              }

              final categories = snapshot.data!.categories;

              return ListView.separated(
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const Divider(color: AppColors.yellow, thickness: 1),
                itemBuilder: (context, index) {
                  return MaterialButton(
                    onPressed: () {
                      _showDuasList(
                          context, categories[index], provider.isDarkMode());
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Text(
                        categories[index].categoryName,
                        style: TextStyle(
                          color: provider.isDarkMode()
                              ? Colors.white
                              : Colors.black,
                          fontSize: 22,
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

  void _showDuasList(BuildContext context, DuasCategory category, bool isDark) {
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
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.yellow),
              ),
              const Divider(color: AppColors.yellow),
              Expanded(
                child: ListView.builder(
                  itemCount: category.duas.length,
                  itemBuilder: (context, index) {
                    final item = category.duas[index];
                    return Card(
                      color: isDark ? Colors.white10 : Colors.grey[100],
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              item.text,
                              style: TextStyle(
                                fontSize: 20,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
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
