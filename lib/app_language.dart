import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage extends ChangeNotifier {
  Locale? _appLocale = const Locale('pt');

  Locale get appLocal => _appLocale ?? const Locale("pt");

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = const Locale('pt');
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == const Locale("pt")) {
      _appLocale = const Locale("pt");
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', '');
    } else if (type == const Locale("es")) {
      _appLocale = const Locale("es");
      await prefs.setString('language_code', 'es');
      await prefs.setString('countryCode', '');
    } else if (type == const Locale("fr")) {
      _appLocale = const Locale("fr");
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = const Locale("en");
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', '');
    }
    notifyListeners();
  }
}
