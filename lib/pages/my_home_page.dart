import 'package:flutter/material.dart';
import 'login_page.dart'; // Make sure this is correctly pointing to the login page

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Assuming an image asset here as a logo
          Center(
            child: Container(
              margin: EdgeInsets.only(top: screenHeight * 0.1),
              child: Image.asset(
                'images/logo1.jpeg',
                width: screenWidth * 0.8,
                height: screenHeight * 0.3,
              ),
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: Size(screenWidth * 0.8, 60),
              backgroundColor: const Color.fromRGBO(21, 135, 112, 1),
              elevation: 10,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(50)),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            child: const Text(
              'Get Started',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}