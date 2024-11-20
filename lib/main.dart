import 'package:flutter/material.dart';
import 'pages/my_home_page.dart'; // Using your existing logo page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green),
      home: MyHomePage(), // Start with your logo page
    );
  }
}
