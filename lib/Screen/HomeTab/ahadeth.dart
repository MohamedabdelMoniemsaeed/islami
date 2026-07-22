import 'package:flutter/material.dart';
import 'package:islami/Screen/quran.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/dezeen/data.dart';
import 'package:islami/dezeen/images.dart';
import 'package:islami/l10n/app_localizations.dart';

class AhadethTab extends StatelessWidget {
  const AhadethTab({super.key});

  static final List<String> ahadethName = List.generate(50, (index) {
    return "الحديث رقم ${index + 1}";
  });

  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    
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
              color: Theme.of(context).scaffoldBackgroundColor == Colors.transparent 
                  ? Colors.transparent 
                  : Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  const Divider(color: AppColors.yellow, thickness: 2, height: 2),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      locale.ahadethName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
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
                          fileName: "h${index + 1}.txt",
                          isQuranfile: false,
                          suraName: ahadethName[index],
                        ),
                      );
                    },
                    child: Text(
                      ahadethName[index],
                      style: Theme.of(context).textTheme.displayMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(color: AppColors.yellow, thickness: 1, height: 1),
                ],
              );
            },
            childCount: ahadethName.length,
          ),
        ),
      ],
    );
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
