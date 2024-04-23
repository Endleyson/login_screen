import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class S {
  late final Locale locale;

  S(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<S> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value!);
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String? translate(String key) {
    return _localizedStrings[key];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<S> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'pt', 'es', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<S> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    S localizations = S(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
