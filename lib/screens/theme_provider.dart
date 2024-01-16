// theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late ThemeData _currentTheme;
  final String _themeKey = 'theme_preference';

  ThemeProvider() {
    _currentTheme = ThemeData.light();
    _loadThemeFromPrefs();
  }

  ThemeData getTheme() => _currentTheme;

  bool get isDarkMode => _currentTheme.brightness == Brightness.dark;

  void toggleDarkMode() {
    _currentTheme = isDarkMode ? ThemeData.light() : ThemeData.dark();
    _saveThemeToPrefs();
    notifyListeners();
  }

  Future<void> _loadThemeFromPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool(_themeKey) ?? false;
    _currentTheme = isDarkMode ? ThemeData.dark() : ThemeData.light();
    notifyListeners();
  }

  Future<void> _saveThemeToPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, isDarkMode);
  }
}

final lightTheme = ThemeData.light();
final darkTheme = ThemeData.dark();
