import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'APP_LOCALE';

class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  Locale _locale;

  LocaleProvider(this._prefs)
      : _locale = Locale(_prefs.getString(_kLocaleKey) ?? 'az');

  Locale get locale => _locale;

  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    await _prefs.setString(_kLocaleKey, languageCode);
    notifyListeners();
  }

  static const supportedLocales = [
    Locale('az'),
    Locale('en'),
    Locale('ru'),
    Locale('ar'),
  ];

  static const localeLabels = {
    'az': 'Azərbaycan',
    'en': 'English',
    'ru': 'Русский',
    'ar': 'العربية',
  };
}
