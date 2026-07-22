import 'package:flutter/material.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/sura_name.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/dezeen/shiar.dart';
import 'package:islami/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

class QuranTab extends StatelessWidget {
  const QuranTab({super.key});

  String _toArabicNumbers(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

    for (int i = 0; i < english.length; i++) {
      input = input.replaceAll(english[i], arabic[i]);
    }
    return input;
  }

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    var provider = Provider.of<AppProvider>(context);

    return CustomScrollView(
      slivers: [
        // الجزء الذي يختفي عند السكرول (العنوان والصورة)
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                locale.islami,
                style: Theme.of(context).appBarTheme.titleTextStyle,
                textAlign: TextAlign.center,
              ),
              Image.asset(
                AppImage.quran,
                height: 200,
              ),
            ],
          ),
        ),

        // الجزء الثابت (الهيدر) بخلفية معتمة تماماً لإخفاء ما خلفه
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverHeaderDelegate(
            child: Container(
              // استخدام لون معتم تماماً (Solid) ليغطي القائمة خلفه
              decoration: BoxDecoration(
                color: provider.isDarkMode() 
                    ? AppColors.yellowDark 
                    : const Color(0xFFF8F8F8), // لون خلفية صلب للفاتح
                border: const Border(
                  top: BorderSide(color: AppColors.yellow, width: 2),
                  bottom: BorderSide(color: AppColors.yellow, width: 2),
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // رقم السورة (يمين - 1/3 العرض)
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          "رقم السورة",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: provider.isDarkMode() ? AppColors.blackDark : Colors.black,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      color: AppColors.yellow,
                    ),
                    // اسم السورة (شمال - 2/3 العرض)
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          locale.suraName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: provider.isDarkMode() ? AppColors.blackDark : Colors.black,
                            fontSize: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // قائمة السور
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
                          fileName: "${index + 1}.txt",
                          isQuranfile: true,
                          suraName: SuraName.listSuraName[index],
                        ),
                      );
                    },
                    child: IntrinsicHeight(
                      child: Row(
                        children: [
                          // الرقم (يمين)
                          Expanded(
                            flex: 1,
                            child: Text(
                              _toArabicNumbers("${index + 1}"),
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: provider.isDarkMode() ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Container(
                            width: 2,
                            color: AppColors.yellow,
                          ),
                          // الاسم (شمال)
                          Expanded(
                            flex: 2,
                            child: Text(
                              SuraName.listSuraName[index],
                              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: provider.isDarkMode() ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: AppColors.yellow, thickness: 1, height: 1),
                ],
              );
            },
            childCount: SuraName.listSuraName.length,
          ),
        ),
      ],
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverHeaderDelegate({required this.child});

  @override
  double get minExtent => 65;
  @override
  double get maxExtent => 65;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return false;
  }
}
