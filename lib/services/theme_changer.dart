import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  bool _isDarkMode;

  ThemeChanger(this._isDarkMode);

  isDarkMode() => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    (await SharedPreferences.getInstance()).setBool('isDarkMode', _isDarkMode);

    notifyListeners();
  }
}
