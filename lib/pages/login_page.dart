import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';
import 'main_navigation.dart'; // Assuming this is the main navigation page
import 'sign_up_page.dart'; // Import your sign-up page here
import '/utils/database_helper.dart'; // Import your DatabaseHelper here
import '/models/user.dart'; // Import your User model
import '../utils/firestore_service.dart'; // Import the FirestoreService

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseHelper _databaseHelper = DatabaseHelper(); // DatabaseHelper instance

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Center(
                child: Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'images/shap.png',
                width: 250,
                height: 250,
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email Input
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    // Password Input
                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        } else if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30),
                    // Login Button
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            // Sign in with Firebase Authentication
                            firebase_auth.UserCredential userCredential = await _auth.signInWithEmailAndPassword(
                              email: emailController.text,
                              password: passwordController.text,
                            );

                            // Check if the user exists in the local database
                            User? localUser = await _databaseHelper.getUserByEmail(emailController.text);

                            if (localUser == null) {
                              // If user is not in local database, sync from Firestore and insert
                              User? firestoreUser = await _firestoreService.getUserFromFirestoreAndSync(emailController.text);

                              if (firestoreUser != null) {
                                // Insert user into local SQLite database
                                await _databaseHelper.insertUser(firestoreUser);

                                // After successful sync, navigate to main navigation
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => MainNavigation(userId: firestoreUser.id!)),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('User not found in Firestore')),
                                );
                              }
                            } else {
                              // If user exists in local database, navigate to main navigation
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => MainNavigation(userId: localUser.id!)),
                              );
                            }
                          } on firebase_auth.FirebaseAuthException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Invalid email or password')),
                            );
                          }
                        }
                      },
                      child: Text('Log In'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // Sign Up Redirect
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpPage()),
                        );
                      },
                      child: Text(
                        "Don’t have an account? Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
