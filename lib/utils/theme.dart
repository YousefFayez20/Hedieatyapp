// utils/theme.dart
import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primaryColor: Color.fromRGBO(21, 135, 112, 1),
  hintColor: Color.fromRGBO(218, 128, 156, 1),
  appBarTheme: AppBarTheme(
    backgroundColor: Color.fromRGBO(21, 135, 112, 1),
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color.fromRGBO(21, 135, 112, 1),
  ),
);