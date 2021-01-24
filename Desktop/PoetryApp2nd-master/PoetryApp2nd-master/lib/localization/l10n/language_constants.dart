import 'package:flutter/material.dart';
import 'package:projectname/localization/l10n/demo_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Author: Khaled
// This file defines language codes, grabs translation text, and sets the language mode.

const String LAGUAGE_CODE = 'languageCode';

//languages code
const String ENGLISH = 'en';
const String FARSI = 'fa';
const String ARABIC = 'ar';
const String Turkish = 'tr';

// The translation language is set here.
Future<Locale> setLocale(String languageCode) async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  await _prefs.setString(LAGUAGE_CODE, languageCode);
  return _locale(languageCode);
}

// The translation language is grabbed here.
Future<Locale> getLocale() async {
  SharedPreferences _prefs = await SharedPreferences.getInstance();
  String languageCode = _prefs.getString(LAGUAGE_CODE) ?? "en";
  return _locale(languageCode);
}

// Different language settings are defined here.
Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH, 'US');
    case FARSI:
      return Locale(FARSI, "IR");
    case ARABIC:
      return Locale(ARABIC, "YE");
    case Turkish:
      return Locale(Turkish, "TR");
    default:
      return Locale(ENGLISH, 'US');
  }
}

// The translated text is grabbed here and returned.
String getTranslated(BuildContext context, String key) {
  return DemoLocalization.of(context).translate(key);
}
