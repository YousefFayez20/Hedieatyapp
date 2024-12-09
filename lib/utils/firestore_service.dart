import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/user.dart';
import '../models/friend.dart';
import '../utils/database_helper.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  // Fetch user from Firestore and sync with SQLite
  Future<User?> syncUserWithFirestore(String email) async {
    try {
      // Check if user exists in Firestore
      var userDoc = await _db.collection('users').doc(email).get();
      if (userDoc.exists) {
        var data = userDoc.data();
        User user = User(
          id: null, // SQLite will assign the ID
          name: data?['name'],
          email: data?['email'],
          password: '', // Do not store password in Firestore
          preferences: data?['preferences'],
        );

        // Sync user data to SQLite if not already present
        User? localUser = await _databaseHelper.getUserByEmail(email);
        if (localUser == null) {
          await _databaseHelper.insertUser(user);
        }

        return user;
      } else {
        print('User not found in Firestore');
        return null;
      }
    } catch (e) {
      print('Error fetching user from Firestore: $e');
      return null;
    }
  }

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

  // Add a user to Firestore
  Future<void> addUserToFirestore(User user) async {
    try {
      await _db.collection('users').doc(user.email).set({
        'name': user.name,
        'email': user.email,
        'preferences': user.preferences ?? 'Default Preferences',
      });
      print('User added to Firestore');
    } catch (e) {
      print('Error adding user to Firestore: $e');
    }
  }

  // Fetch all friends of a user from Firestore and sync with SQLite
  Future<List<Friend>> syncFriendsWithFirestore(String email, int userId) async {
    try {
      // Fetch friends from Firestore
      var friendDocs = await _db.collection('users')
          .doc(email) // Use the user's email to fetch the friends
          .collection('friends')
          .get();

      List<Friend> friends = [];
      for (var doc in friendDocs.docs) {
        var data = doc.data();
        Friend friend = Friend(
          id: null, // SQLite will generate the ID
          name: data['name'],
          profileImage: data['profile_image'],
          upcomingEvents: data['upcoming_events'],
          userId: userId, // Not needed here for Firestore sync
          firebaseId: doc.id, // Firestore document ID
        );

        // Sync the friend data to SQLite
        Friend? localFriend = await _databaseHelper.getFriendByFirebaseId(friend.firebaseId!);
        if (localFriend == null) {
          await _databaseHelper.insertFriend(friend);
        }

        friends.add(friend);
      }

      return friends;
    } catch (e) {
      print('Error syncing friends: $e');
      return [];
    }
  }

  Future<void> addFriendToFirestore(Friend friend, String email) async {
    try {
      await _db.collection('users')
          .doc(email) // Use email as the user identifier
          .collection('friends')
          .doc(friend.firebaseId) // Use firebaseId as the document ID
          .set({
        'name': friend.name,
        'profile_image': friend.profileImage,
        'upcoming_events': friend.upcomingEvents,
      });

      print('Friend added to Firestore');
    } catch (e) {
      print('Error adding friend to Firestore: $e');
    }
  }
  Future<void> syncEventsWithFirestore(int userId, String email) async {
    try {
      // Fetch events from Firestore for the user
      var eventDocs = await _db.collection('users')
          .doc(email)
          .collection('events')
          .get();

      for (var doc in eventDocs.docs) {
        var data = doc.data();
        Event event = Event(
          id: null, // SQLite will generate the ID
          name: data['name'],
          description: data['description'],
          location: data['location'],
          category: data['category'],
          date: (data['date'] as Timestamp).toDate(),
          userId: userId,
          friendId: data['friend_id'],
          status: data['status'],

        );

        // Sync event to SQLite if not already present
        if (event.id != null) {
          Event? localEvent = await _databaseHelper.fetchEventById(event.id!);
          if (localEvent == null) {
            await _databaseHelper.insertEvent(event);
          }
        } else {
          print("Event ID is null");
        }
      }
    } catch (e) {
      print('Error syncing events from Firestore: $e');
    }
  }

  // Add event to Firestore
  Future<void> addEventToFirestore(Event event, String email) async {
    try {
      await _db.collection('users')
          .doc(email)
          .collection('events')
          .add({
        'name': event.name,
        'description': event.description,
        'location': event.location,
        'category': event.category,
        'date': event.date,
        'friend_id': event.friendId,
        'status': event.status,
      });
      print('Event added to Firestore');
    } catch (e) {
      print('Error adding event to Firestore: $e');
    }
  }
  Future<List<Event>> fetchEventsFromFirestore(int userId,email) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(email) // or use the user ID
          .collection('events')
          .get();

      List<Event> events = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return Event(
          id: null, // SQLite will generate the ID
          name: data['name'],
          description: data['description'],
          location: data['location'],
          category: data['category'],
          date: (data['date'] as Timestamp).toDate(),
          userId: userId,
          friendId: data['friend_id'],
          status: data['status'],
        );
      }).toList();

      return events;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

}
