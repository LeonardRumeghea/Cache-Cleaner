import 'package:cache_cleaner/entities/constants.dart';
import 'package:cache_cleaner/screens/main_screen.dart';
import 'package:cache_cleaner/services/theme_changer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const CacheCleanerApp());
}

class CacheCleanerApp extends StatelessWidget {
  const CacheCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return ChangeNotifierProvider<ThemeChanger>(
      create: (_) => ThemeChanger(
        MediaQuery.of(context).platformBrightness == Brightness.dark
            ? darkTheme
            : lightTheme,
      ),
      child: const MaterialAppWithTheme(),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  const MaterialAppWithTheme({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    changeTextColorTheme(theme.getTheme() == darkTheme);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
      theme: theme.getTheme(),
    );
  }
}
