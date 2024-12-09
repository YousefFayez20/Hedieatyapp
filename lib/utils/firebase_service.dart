
/*
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/user.dart' as u; // Aliasing your custom User model as 'u'
import 'database_helper.dart'; // Your DatabaseHelper

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new user with Firebase Authentication
  Future<firebase_auth.User?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user with Firebase Authentication
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally, add the user's name to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });

      // Create a custom User object for SQLite
      u.User user = u.User( // Use 'u.User' for your custom model
        id: null, // SQLite will auto-increment this
        name: name,
        email: email,
        password: password,
        preferences: null,
      );

      // Insert the user into SQLite database using DatabaseHelper
      await DatabaseHelper().insertUser(user);

      return userCredential.user; // Return Firebase user object
    } on FirebaseAuthException catch (e) {
      print("Error during sign-up: ${e.message}");
      return null;
    }
  }

  // Login with email and password
  Future<firebase_auth.User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user already exists in SQLite
      final dbUser = await DatabaseHelper().getUserByEmail(email);
      if (dbUser == null) {
        // If not found in SQLite, fetch from Firestore and insert into SQLite
        DocumentSnapshot userData = await getUserData(userCredential.user!.uid);
        String name = userData['name'] ?? '';
        String email = userData['email'] ?? '';

        // Create and insert the user into SQLite
        u.User newUser = u.User( // Use 'u.User' for your custom model
          id: null,
          name: name,
          email: email,
          password: password,
          preferences: null,
        );
        await DatabaseHelper().insertUser(newUser);
      }

      return userCredential.user; // Return Firebase user object
    } on FirebaseAuthException catch (e) {
      print("Error during login: ${e.message}");
      return null;
    }
  }

  // Get current user (if logged in)
  firebase_auth.User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Sign out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fetch user data from Firestore by UID
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

  
  String? getLoggedInEmail() {
    return _auth.currentUser?.email;
  }
}
*/