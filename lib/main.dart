import 'package:cache_cleaner/entities/constants.dart';
import 'package:cache_cleaner/screens/main_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const CacheCleanerApp());
}

class CacheCleanerApp extends StatelessWidget {
  const CacheCleanerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: const ColorScheme.dark(
            primary: primaryColor, inversePrimary: primaryColor),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
