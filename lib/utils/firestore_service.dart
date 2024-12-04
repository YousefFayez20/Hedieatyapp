import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
import '../models/friend.dart';
import 'database_helper.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

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

  // Fetch user from Firestore by email and sync with local database
  Future<User?> getUserFromFirestoreAndSync(String email) async {
    try {
      var userDoc = await _db.collection('users').doc(email).get();
      if (userDoc.exists) {
        var data = userDoc.data();
        User userFromFirestore = User(
          id: null,  // Firestore does not have an "id" field, so we leave it null
          name: data?['name'],
          email: data?['email'],
          password: '',  // Password is not stored in Firestore, leave it empty
          preferences: data?['preferences'],
        );

        // Check if user is in local SQLite database
        User? localUser = await _databaseHelper.getUserByEmail(email);
        if (localUser == null) {
          // Insert the user into the local SQLite database if not found
          await _databaseHelper.insertUser(userFromFirestore);
        }
        return userFromFirestore;
      } else {
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      print("Error fetching user from Firestore: $e");
      return null;
    }
  }
  Future<void> syncFriendWithFirebase(Friend friend) async {
    try {
      // Reference to Firestore collection for friends
      final userRef = FirebaseFirestore.instance.collection('users')
          .doc(friend.userId.toString())  // Assuming userId is available
          .collection('friends');

      // Add or update friend in Firestore
      if (friend.firebaseId == null) {
        // Friend does not have a Firebase ID yet, create a new document
        final docRef = await userRef.add({
          'name': friend.name,
          'profile_image': friend.profileImage,
          'upcoming_events': friend.upcomingEvents,
        });

        // Update the local SQLite database with the Firebase ID
        friend = friend.copyWith(firebaseId: docRef.id);  // Get Firebase document ID

        // Update local database with Firebase ID
        final dbHelper = DatabaseHelper();
        await dbHelper.updateFriend(friend);  // Update SQLite record with Firebase ID
      } else {
        // If the friend already has a Firebase ID, update the existing document
        await userRef.doc(friend.firebaseId).update({
          'name': friend.name,
          'profile_image': friend.profileImage,
          'upcoming_events': friend.upcomingEvents,
        });
      }

      print('Friend synced successfully with Firebase!');
    } catch (e) {
      print('Error syncing friend with Firebase: $e');
    }
  }


}