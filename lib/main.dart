import 'package:cache_cleaner/entities/constants.dart';
import 'package:cache_cleaner/screens/main_screen.dart';
import 'package:cache_cleaner/services/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dynamic_color/dynamic_color.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool isDarkMode =
      (await SharedPreferences.getInstance()).getBool('isDarkMode') ??
          ThemeMode.system == ThemeMode.dark;

  runApp(CacheCleanerApp(isDarkMode));
}

class CacheCleanerApp extends StatelessWidget {
  const CacheCleanerApp(this.isDarkMode, {super.key});

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(isDarkMode),
      child: const MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    changeTextColorTheme(theme.isDarkMode());
    return DynamicColorBuilder(builder: (lightColorScheme, darkColorScheme) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: lightColorScheme, useMaterial3: true),
        darkTheme: ThemeData(colorScheme: darkColorScheme, useMaterial3: true),
        themeMode: theme.isDarkMode() ? ThemeMode.dark : ThemeMode.light,
        home: const HomeScreen(),
      );
    });
  }
}
