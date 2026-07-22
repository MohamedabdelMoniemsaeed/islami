import 'package:flutter/material.dart';
import 'package:islami/dezeen/colors.dart';
import 'package:islami/l10n/app_localizations.dart';

class AzkarTab extends StatelessWidget {
  const AzkarTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.azkar,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.yellow),
      ),
    );
  }
}
