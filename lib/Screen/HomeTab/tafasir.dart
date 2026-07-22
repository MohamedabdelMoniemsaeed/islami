import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';

class TafasirTab extends StatelessWidget {
  const TafasirTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.tafasir,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.yellow),
      ),
    );
  }
}
