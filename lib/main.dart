import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:trial15/utils/database_helper.dart';
import 'utils/theme.dart';  // Make sure this import path is correct
import 'pages/my_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final DatabaseHelper dbHelper = DatabaseHelper();

  // Reset the database
  //await dbHelper.resetDatabase();
  await dbHelper.database;

  // Run the app
  runApp( MyApp());
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