import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      'internetConnected': 'تم الاتصال بالإنترنت',
      'internetDisconnected': 'انقطع الاتصال بالإنترنت',
    },
  };

  String get internetConnected =>
      _localizedValues[locale.languageCode]?['internetConnected'] ?? 'Connected';

  String get internetDisconnected =>
      _localizedValues[locale.languageCode]?['internetDisconnected'] ?? 'Disconnected';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
