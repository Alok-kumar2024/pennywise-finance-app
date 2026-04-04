import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorSchemeSeed: Colors.green,
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorSchemeSeed: Colors.greenAccent,
    scaffoldBackgroundColor: const Color(0xFF121212)
  );

}