import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import '../models/gift.dart';
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
      print("Starting event sync from Firestore for email: $email and userId: $userId");
      // Fetch events from Firestore for the user
      var eventDocs = await _db.collection('users')
          .doc(email)
          .collection('events')
          .get();
      print("Fetched ${eventDocs.docs.length} events from Firestore");
      for (var doc in eventDocs.docs) {
        var data = doc.data();
        print("Processing event: ${data['name']}");
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
        print("Converted Firestore event to Event object: ${event.toMap()}");
        // Sync event to SQLite if not already present
        List<Event> existingEvents = await _databaseHelper.fetchEventsByUserId(userId);
        bool isDuplicate = existingEvents.any((e) => e.name == event.name && e.date == event.date);

        if (!isDuplicate) {
          print("Inserting event into SQLite: ${event.name}");
          await _databaseHelper.insertEvent(event);
        } else {
          print("Event already exists in SQLite: ${event.name}");
        }
      }
    } catch (e) {
      print("Error syncing events from Firestore: $e");
    }
  }
  Future<void> syncGiftsForFriendEventWithFirestore(
      int userId, String email, String friendFirebaseId, String eventFirebaseId, int eventId) async {
    try {
      // Fetch gifts from Firestore for the friend's event
      var giftDocs = await _db
          .collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts')
          .get();

      for (var doc in giftDocs.docs) {
        var data = doc.data();
        Gift gift = Gift(
          id: null, // Firestore ID will be used as the local ID
          name: data['name'],
          price: data['price'].toDouble(),
          description: data['description'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          status: data['status'],
          category: data['category'],
          eventId: eventId
        );

        // Sync gift to SQLite if not already present
        Gift? localGift = await _databaseHelper.getGiftByFirebaseId(gift.giftFirebaseId!);
        if (localGift == null) {
          await _databaseHelper.insertGift(gift);
          print('Gift inserted into SQLite: ${gift.name}');
        } else {
          print('Gift already exists in SQLite: ${gift.name}');
        }
      }
    } catch (e) {
      print('Error syncing gifts for friend\'s event from Firestore: $e');
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
    print("Fetching events from Firestore for email: $email");
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(email) // or use the user ID
          .collection('events')
          .get();
      print("Fetched ${querySnapshot.docs.length} events from Firestore");
      List<Event> events = querySnapshot.docs.map((doc) {
        var data = doc.data();
        print("Processing event: ${data['name']} (Firestore data: $data)");
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
  Future<List<Event>> fetchFriendEventsFromFirestore(int userId, String email, String friendFirebaseId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(email) // User's email
          .collection('friends') // Accessing the friend's collection
          .doc(friendFirebaseId) // Firebase ID of the friend
          .collection('events') // Friend's events collection
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
          friendId: data['friend_id'], // Passing Firebase ID of the friend
          status: data['status'],
        );
      }).toList();

      return events;
    } catch (e) {
      print("Error fetching friend events: $e");
      return [];
    }
  }
  Future<List<Gift>> fetchGiftsForFriendEvent(
      String email, String friendFirebaseId, String eventFirebaseId) async {
    try {
      final querySnapshot = await _db
          .collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts')
          .get();

      List<Gift> gifts = querySnapshot.docs.map((doc) {
        var data = doc.data();
        return Gift(
          id: null, // Firestore gift ID
          name: data['name'],
          price: data['price'].toDouble(),
          description: data['description'],
          createdAt: (data['createdAt'] as Timestamp).toDate(),
          updatedAt: (data['updatedAt'] as Timestamp).toDate(),
          status: data['status'],
          category: data['category'],
            giftFirebaseId: doc.id

        );
      }).toList();

      return gifts;
    } catch (e) {
      print("Error fetching gifts for friend's event: $e");
      return [];
    }
  }




  Future<void> addFriendEventToFirestore(Event event, String email, String friendFirebaseId) async {
    try {
      await _db.collection('users')
          .doc(email) // User's email
          .collection('friends') // Friend's collection
          .doc(friendFirebaseId) // Friend's Firebase ID
          .collection('events') // Friend's events collection
          .add({
        'name': event.name,
        'description': event.description,
        'location': event.location,
        'category': event.category,
        'date': event.date,
        'status': event.status,
      });

      print('Friend event added to Firestore');
    } catch (e) {
      print('Error adding friend event to Firestore: $e');
    }
  }
  Future<void> addGiftToFriendEvent(
      String email, String friendFirebaseId, String eventFirebaseId, Gift gift) async {
    try {
      print("Adding gift to Firestore...");
      print("Firestore Path: users/$email/friends/$friendFirebaseId/events/$eventFirebaseId/gifts");
      print("Gift Details: ${gift.toMap()}");

      await _db
          .collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts')
          .add({
        'name': gift.name,
        'price': gift.price,
        'description': gift.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'status': gift.status,
        'category': gift.category,
      });

      print('Gift added successfully to Firestore.');
    } catch (e) {
      print('Error adding gift to Firestore: $e');
    }
  }


  Future<void> updateGiftStatus(
      String email, String friendFirebaseId, String eventFirebaseId, String giftFirebaseId, String newStatus) async {
    try {
      await _db
          .collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts')
          .doc(giftFirebaseId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(), // Update timestamp
      });

      print('Gift status updated');
    } catch (e) {
      print('Error updating gift status: $e');
    }
  }
  Future<void> deleteGiftFromFriendEvent(
      String email, String friendFirebaseId, String eventFirebaseId, String giftFirebaseId) async {
    try {
      await _db
          .collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .doc(eventFirebaseId)
          .collection('gifts')
          .doc(giftFirebaseId)
          .delete();

      print('Gift deleted from friend\'s event');
    } catch (e) {
      print('Error deleting gift from friend\'s event: $e');
    }
  }

  Future<void> syncFriendEventsWithFirestore(int userId, String? email, String friendFirebaseId) async {
    if (email == null) {
      print("Error: No email found for the given user ID");
      return;
    }

    try {
      // Fetch events of the friend using Firebase ID
      var eventDocs = await _db.collection('users')
          .doc(email)
          .collection('friends')
          .doc(friendFirebaseId)
          .collection('events')
          .get();
      print("Fetched ${eventDocs.docs.length} events for friend");
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
          friendId: await _databaseHelper.getFriendIdByFirebaseId(friendFirebaseId),
          // Assuming friendId will be resolved by FirebaseId
          firebaseId: doc.id, // Use Firestore doc ID as Firebase ID
          status: data['status'],
        );

        // Sync event to SQLite
        print("Converted Firestore event to Event object: ${event.toMap()}");

        // Sync event to SQLite if not already present
        List<Event> existingEvents = await _databaseHelper.fetchEventsByFriendId(event.friendId!);
        bool isDuplicate = existingEvents.any((e) => e.name == event.name && e.date == event.date);

        if (!isDuplicate) {
          print("Inserting friend event into SQLite: ${event.name}");
          await _databaseHelper.insertEvent(event);
        } else {
          print("Friend event already exists in SQLite: ${event.name}");
        }
      }
    } catch (e) {
      print('Error syncing friend events from Firestore: $e');
    }
  }
}
