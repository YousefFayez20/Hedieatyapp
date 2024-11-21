import 'package:flutter/material.dart';
import 'utils/theme.dart';  // Make sure this import path is correct
import 'pages/my_home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      debugShowCheckedModeBanner: false,
      theme: appTheme,  // Apply your custom theme here
      home: MyHomePage(),
    );
  }
}
