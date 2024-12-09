import 'package:flutter/material.dart';

class AppTexts {
  static TextTheme lightTextTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
  );

  static TextTheme darkTextTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.white),
    titleLarge: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white),
    bodyMedium: TextStyle(fontSize: 14.0, color: Colors.white54),
  );
}
