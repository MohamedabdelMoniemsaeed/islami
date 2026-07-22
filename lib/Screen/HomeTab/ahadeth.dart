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

class AhadethTab extends StatelessWidget {
  const AhadethTab({super.key});

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var provider = Provider.of<AppProvider>(context);
    final ApiService apiService = ApiService();

    return Column(
      children: [
        // الجزء الذي يختفي عند السكرول (العنوان والصورة)
        // ملاحظة: بما أننا نريد السكرول للكل، سنستخدم FutureBuilder داخل CustomScrollView
        Expanded(
          child: FutureBuilder<HadithResponse>(
            future: apiService.getHadiths('abu-dawud', 1),
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

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Text(
                          locale.islami,
                          style: Theme.of(context).appBarTheme.titleTextStyle,
                          textAlign: TextAlign.center,
                        ),
                        Image.asset(AppImage.psmallh, height: 200),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverHeaderDelegate(
                      child: Container(
                        color: provider.isDarkMode() ? AppColors.yellowDark : const Color(0xFFF8F8F8),
                        child: Column(
                          children: [
                            const Divider(color: AppColors.yellow, thickness: 2, height: 2),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "أحاديث أبي داود",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: provider.isDarkMode() ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                            const Divider(color: AppColors.yellow, thickness: 2, height: 2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Column(
                          children: [
                            MaterialButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  QuranScreen.routeName,
                                  arguments: DataQuran(
                                    fileName: "api_hadith_${hadiths[index].number}",
                                    isQuranfile: false,
                                    suraName: "الحديث رقم ${_toArabicNumbers(hadiths[index].number.toString())}",
                                    content: hadiths[index].arab,
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Text(
                                  "الحديث رقم ${_toArabicNumbers(hadiths[index].number.toString())}",
                                  style: Theme.of(context).textTheme.displayMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const Divider(color: AppColors.yellow, thickness: 1, height: 1),
                          ],
                        );
                      },
                      childCount: hadiths.length,
                    ),
                  ),
                ],
              );
            },
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

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _SliverHeaderDelegate({required this.child});

  @override double get minExtent => 70;
  @override double get maxExtent => 70;
  @override Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => child;
  @override bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) => false;
}
