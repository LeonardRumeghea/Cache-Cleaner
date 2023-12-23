import 'package:cache_cleaner/entities/constants.dart';
import 'package:flutter/material.dart';

class ThemeChanger with ChangeNotifier {
  ThemeData _themeData;

  ThemeChanger(this._themeData);

  getTheme() => _themeData;

  void toggleTheme() {
    _themeData = _themeData == darkTheme ? lightTheme : darkTheme;
    notifyListeners();
  }
}
