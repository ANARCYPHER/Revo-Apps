import 'package:flutter/material.dart';
import 'package:nyoba/app_theme/storage_manager.dart';
import 'package:nyoba/utils/utility.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotifier extends ChangeNotifier {
  Locale _appLocale = Locale('en');
  bool isDarkMode = false;

  int? selectedLocaleIndex = 0;

  Locale get appLocal => _appLocale;

  ThemeData? _themeData;
  ThemeData? getTheme() => _themeData;

  AppNotifier() {
    StorageManager.readData('themeMode').then((value) {
      print('value read from storage: ' + value.toString());
      var themeMode = value ?? 'light';
      if (themeMode == 'light') {
        _themeData = lightTheme;
        isDarkMode = false;
      } else {
        print('setting dark theme');
        _themeData = darkTheme;
        isDarkMode = true;
      }
      notifyListeners();
    });
  }

  fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString('language_code') == null) {
      _appLocale = Locale('en');
      prefs.setString('language_code', 'en');
      return Null;
    }
    if (prefs.getInt('localeIndex') == null) {
      selectedLocaleIndex = 0;
      return Null;
    }
    _appLocale = Locale(prefs.getString('language_code')!);
    selectedLocaleIndex = prefs.getInt('localeIndex');
    print(_appLocale);
    return Null;
  }

  void changeLanguage(Locale type) async {
    var prefs = await SharedPreferences.getInstance();
    if (_appLocale == type) {
      return;
    }
    if (type == Locale("id")) {
      _appLocale = Locale("id");
      selectedLocaleIndex = 1;
      await prefs.setString('language_code', 'id');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("es")) {
      _appLocale = Locale("es");
      selectedLocaleIndex = 2;
      await prefs.setString('language_code', 'es');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("fr")) {
      _appLocale = Locale("fr");
      selectedLocaleIndex = 3;
      await prefs.setString('language_code', 'fr');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("zh")) {
      _appLocale = Locale("zh");
      selectedLocaleIndex = 4;
      await prefs.setString('language_code', 'zh');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("ja")) {
      _appLocale = Locale("ja");
      selectedLocaleIndex = 5;
      await prefs.setString('language_code', 'ja');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("ko")) {
      _appLocale = Locale("ko");
      selectedLocaleIndex = 6;
      await prefs.setString('language_code', 'ko');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("ar")) {
      _appLocale = Locale("ar");
      selectedLocaleIndex = 7;
      await prefs.setString('language_code', 'ar');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("pt")) {
      _appLocale = Locale("pt");
      selectedLocaleIndex = 8;
      await prefs.setString('language_code', 'pt');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("nl")) {
      _appLocale = Locale("nl");
      selectedLocaleIndex = 9;
      await prefs.setString('language_code', 'nl');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("de")) {
      _appLocale = Locale("de");
      selectedLocaleIndex = 10;
      await prefs.setString('language_code', 'de');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("tr")) {
      _appLocale = Locale("tr");
      selectedLocaleIndex = 11;
      await prefs.setString('language_code', 'tr');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("he")) {
      _appLocale = Locale("he");
      selectedLocaleIndex = 12;
      await prefs.setString('language_code', 'he');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("hi")) {
      _appLocale = Locale("hi");
      selectedLocaleIndex = 13;
      await prefs.setString('language_code', 'hi');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("te")) {
      _appLocale = Locale("te");
      selectedLocaleIndex = 14;
      await prefs.setString('language_code', 'te');
      await prefs.setString('countryCode', '');
    } else if (type == Locale("ms")) {
      _appLocale = Locale("ms");
      selectedLocaleIndex = 15;
      await prefs.setString('language_code', 'ms');
      await prefs.setString('countryCode', '');
    } else {
      _appLocale = Locale("en");
      selectedLocaleIndex = 0;
      await prefs.setString('language_code', 'en');
      await prefs.setString('countryCode', 'US');
    }
    await prefs.setInt('localeIndex', selectedLocaleIndex!);
    print(type);
    notifyListeners();
  }

  final lightTheme = ThemeData.light().copyWith(
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(color: Colors.black),
      iconTheme: IconThemeData(color: Colors.black),
      // actionsIconTheme:
    ),
    primaryColor: primaryColor,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Poppins',
        ),
    primaryTextTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Poppins',
        ),
  );

  final darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    textTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Poppins',
        ),
    primaryTextTheme: ThemeData.dark().textTheme.apply(
          fontFamily: 'Poppins',
        ),
  );

  void setDarkMode() async {
    _themeData = darkTheme;
    StorageManager.saveData('themeMode', 'dark');
    notifyListeners();
  }

  void setLightMode() async {
    _themeData = lightTheme;
    StorageManager.saveData('themeMode', 'light');
    notifyListeners();
  }
}
