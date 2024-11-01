// utils/theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Colors.deepPurple,
  hintColor: Colors.purpleAccent,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.deepPurple,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.deepPurple,
  ),
);
