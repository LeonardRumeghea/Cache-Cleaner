import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
      primary: primaryColor, inversePrimary: primaryColor),
  useMaterial3: true,
);

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
      primary: primaryColor, inversePrimary: primaryColor),
  useMaterial3: true,
);

// const Color primaryColor = Color(0xFF0D47A1);
const Color primaryColor = Color(0xFF36583C);
const Color successColor = Color(0xFF76AA74);

// ------------------ Text Color ------------------
Color _primaryTextColorDark = Colors.grey.shade200;
Color _secondaryTextColorDark = Colors.grey.shade400;
Color _unableTextColorDark = Colors.grey.shade500;

Color _primaryTextColoLight = Colors.grey.shade900;
Color _secondaryTextColorLight = Colors.grey.shade700;
Color _unableTextColorLight = Colors.grey.shade500;

Color primaryTextColor = _primaryTextColorDark;
Color secondaryTextColor = _secondaryTextColorDark;
Color unableTextColor = _unableTextColorDark;

Color appbarTextColor = Colors.grey.shade200;

// ------------------ Text Size ------------------
double primaryTextSize = 20;
double secondaryTextSize = 15;
double popupMenuTextSize = 18;

// ------------------ Card Constants ------------------
Color _cardGreyColorDark = Colors.grey.shade900;
Color _cardGreyColorLight = Colors.grey.shade200;
Color cardGreyColor = _cardGreyColorDark;

const int nameMaxLength = 15;
const double borderRadius = 10.0;

const BoxShadow cardBoxShadow = BoxShadow(
  color: Colors.black12,
  blurRadius: 5.0,
  offset: Offset(0.0, 5.0),
);

void changeTextColorTheme(bool isDark) {
  primaryTextColor = isDark ? _primaryTextColorDark : _primaryTextColoLight;
  secondaryTextColor =
      isDark ? _secondaryTextColorDark : _secondaryTextColorLight;
  unableTextColor = isDark ? _unableTextColorDark : _unableTextColorLight;
  cardGreyColor = isDark ? _cardGreyColorDark : _cardGreyColorLight;
}

Size screenSize(BuildContext context) => MediaQuery.of(context).size;
double cardWidth(BuildContext context) => screenSize(context).width * 0.9;
double cardHeight(BuildContext context) => screenSize(context).height * 0.1;
double cardIconSize(BuildContext context) => screenSize(context).height * 0.06;
double cardVerticalPadding(BuildContext context) =>
    screenSize(context).height * 0.01;
double cardHorizontalPadding(BuildContext context) =>
    screenSize(context).width * 0.05;

double drawerBottomHeight(BuildContext context) =>
    screenSize(context).height * 0.085;
double drawerBottomWidth(BuildContext context) =>
    screenSize(context).width * 0.9;
