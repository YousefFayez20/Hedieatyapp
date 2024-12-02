import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add user to Firestore
  Future<void> addUserToFirestore(User user) async {
    try {
      await _db.collection('users').doc(user.email).set({
        'name': user.name,
        'email': user.email,
        'preferences': user.preferences ?? 'Default Preferences',
      });
    } catch (e) {
      print("Error adding user to Firestore: $e");
    }
  }

  // Fetch user from Firestore by email
  Future<User?> getUserFromFirestore(String email) async {
    try {
      var userDoc = await _db.collection('users').doc(email).get();
      if (userDoc.exists) {
        var data = userDoc.data();
        return User(
          id: null,  // Firestore does not use IDs like SQLite does
          name: data?['name'],
          email: data?['email'],
          password: '',  // Dummy password for Firestore (not used)
          preferences: data?['preferences'],
        );
      } else {
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      print("Error fetching user from Firestore: $e");
      return null;
    }
  }
}
