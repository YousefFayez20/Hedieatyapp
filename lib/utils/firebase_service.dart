import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/models/user.dart'; // Your User model (if you're using it)

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new user with Firebase Authentication
  Future<UserCredential?> signUpWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Optionally, you can also add the user's name to Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
      });

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Error during sign-up: ${e.message}");
      return null;
    }
  }

  // Login with email and password
  Future<UserCredential?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
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

  // Optionally, you can add Firestore CRUD operations here
  Future<DocumentSnapshot> getUserData(String uid) async {
    try {
      return await _firestore.collection('users').doc(uid).get();
    } catch (e) {
      print("Error fetching user data: $e");
      rethrow;
    }
  }

// Other Firebase operations like reset password can be added here
}
