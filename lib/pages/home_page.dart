import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:trial15/pages/event_edit_page.dart';
import '../models/friend.dart';
import '../utils/bounce_button.dart';
import '../utils/fade_page_transition.dart';
import 'add_friend_dialog.dart';
import 'friend_gift_list_page.dart';
import 'add_event_page.dart';
import '../models/event.dart';
import '../utils/database_helper.dart';
import '../utils/firestore_service.dart';
import 'notification_center_page.dart'; // Import FirestoreService
import '../utils/bounce_button.dart';
class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService =
      FirestoreService(); // Firestore service instance

  List<Friend> friends = [];
  String searchQuery = '';
  String sortOption = 'Total Events';
  String? _userEmail;
  bool _isLoading = true;
  List<Event> _events = [];
  @override
  void initState() {
    super.initState();
    _fetchFriends();
    _initializeEmail();
  }

  Future<void> _initializeEmail() async {
    _userEmail = await _databaseHelper.getEmailByUserId(widget.userId);
    _setupNotificationListener(_userEmail!);
    setState(() {}); // Update the UI after fetching the email
  }

  // Fetch all friends and calculate the total number of events dynamically
  Future<void> _fetchFriends() async {
    try {
      // Sync friends with Firestore and update the local list
      await _syncFriendsWithFirestore();

      // After syncing, fetch all friends from the local database (SQLite)
      final fetchedFriends =
          await _databaseHelper.fetchAllFriends(widget.userId);

      // For each friend, fetch the total count of events
      for (var friend in fetchedFriends) {
        final eventCount =
            await _databaseHelper.fetchTotalEventCountByFriendId(friend.id!);
        friend.upcomingEvents =
            eventCount; // Use the same field for total events
      }

      setState(() {
        friends = fetchedFriends;
      });

      print(
          'Fetched friends: ${friends.map((friend) => friend.toMap()).toList()}');
    } catch (error) {
      print('Error fetching friends: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch friends.')),
      );
    }
  }

  void _setupNotificationListener(String email) {
    _firestoreService.listenForNotifications(email, (message) {
      // Show a SnackBar for in-app notification
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      NotificationCenterPage(userId: widget.userId),
                ),
              );
            },
          ),
        ),
      );
    });
  }

  // Sync the friends data with Firestore and update the local SQLite database
  Future<void> _syncFriendsWithFirestore() async {
    try {
      final email = await _databaseHelper.getEmailByUserId(widget.userId);
      if (email == null) {
        print("Error: No email found for the given user ID");
        return;
      }

      // Fetch synced friends from Firestore
      List<Friend> syncedFriends = await _firestoreService
          .syncFriendsWithFirestore(email, widget.userId);
      print('Synced friends: ${syncedFriends.map((f) => f.toMap()).toList()}');

      // Update local database with Firestore friends (insert or update)
      for (var friend in syncedFriends) {
        // Check if the friend already exists in the local database
        final existingFriend =
            await _databaseHelper.fetchFriendByFirebaseId(friend.firebaseId!);
        if (existingFriend == null) {
          // Insert the friend if it doesn't exist
          final insertedId = await _databaseHelper.insertFriend(friend);
          friend = friend.copyWith(id: insertedId); // Ensure the ID is not null
        } else {
          // Update the existing friend if they already exist
          await _databaseHelper.insertOrUpdateFriend(friend);
        }
      }

      // Update the state with the synced friends
      setState(() {
        friends = syncedFriends;
      });
    } catch (e) {
      print('Error syncing friends with Firestore: $e');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sync friends with Firestore.')));
    }
  }

  Future<void> _addOrEditEvent(Event? event) async {
    if (event == null) {
      final result = await Navigator.push(
        context,
        FadePageTransition(page: AddEventPage(
          onAdd: (newEvent) async {
            if (_userEmail == null) return;
            if (newEvent.friendId != null) {
              final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(newEvent.friendId!);
              await _firestoreService.addFriendEventToFirestore(
                newEvent,
                _userEmail!,
                friendFirebaseId!,
              );
            } else {
              await _firestoreService.addEventToFirestore(newEvent, _userEmail!);
            }
            await _databaseHelper.insertEvent(newEvent);
            await _syncAndFetchEvents();
          },
          userId: widget.userId,
          friends: friends,
        )),
      );


      if (result == true) {
        await _syncAndFetchEvents();
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventEditPage(event: event, userId: widget.userId),
        ),
      );

      if (result == true) {
        await _syncAndFetchEvents();
      }
    }
  }
  void _navigateToFriendGifts(Friend friend) {
    if (friend.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This friend does not have a valid ID.')),
      );
      return;
    }
    Navigator.push(
      context,
      FadePageTransition(
        page: FriendGiftListPage(friendId: friend.id!),
      ),
    );
  }
  Future<void> _syncAndFetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (_userEmail == null) throw Exception("User email not found!");

      // Sync events from Firestore to SQLite
      await _firestoreService.syncEventsWithFirestore(widget.userId, _userEmail!);

      // Fetch friends and their events
      final friendss = await _databaseHelper.fetchAllFriends(widget.userId);
      for (var friend in friends) {
        if (friend.firebaseId != null) {
          await _firestoreService.syncFriendEventsWithFirestore(
            widget.userId,
            _userEmail!,
            friend.firebaseId!,
          );
        }
      }

      // Fetch events from SQLite
      final personalEvents = await _databaseHelper.fetchEventsForUser(widget.userId, friendId: null);
      List<Event> friendEvents = [];
      for (var friend in friends) {
        final eventsForFriend = await _databaseHelper.fetchEventsByFriendId(friend.id!);
        friendEvents.addAll(eventsForFriend);
      }

      setState(() {
        _events = personalEvents + friendEvents;
        friends = friendss;
      });
    } catch (e) {
      print('Error syncing or fetching events: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load events.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // Filter friends based on the search query
    List<Friend> filteredFriends = friends
        .where((friend) =>
            friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Events'),
        backgroundColor: Colors.teal,
        actions: [
          // Notification Icon with Badge
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(_userEmail)
                .collection('notifications')
                .where('isRead', isEqualTo: false)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              int unreadCount =
                  snapshot.hasData ? snapshot.data!.docs.length : 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              NotificationCenterPage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 10,
                        backgroundColor: Colors.red,
                        child: Text(
                          '$unreadCount',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Popup Menu for Sorting
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
                if (value == 'Alphabetically') {
                  friends.sort((a, b) => a.name.compareTo(b.name));
                } else if (value == 'Total Events') {
                  friends.sort(
                      (a, b) => b.upcomingEvents.compareTo(a.upcomingEvents));
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Total Events', 'Alphabetically'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          // Create Event Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BounceButton(
              onTap: () => _addOrEditEvent(null),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                height: 50,
                child: const Text(
                  'Create Your Own Event/List',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Friends List
          Expanded(
            child: filteredFriends.isEmpty
                ? const Center(
                    child: Text(
                      'No friends found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchFriends,
                    child: ListView.builder(
                      itemCount: filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = filteredFriends[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundImage: friend.profileImage.isNotEmpty
                                  ? AssetImage(friend.profileImage)
                                  : const AssetImage(
                                      'assets/default_profile.png'),
                            ),
                            title: Text(
                              friend.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal,
                              ),
                            ),
                            subtitle: Text(
                              friend.upcomingEvents > 0
                                  ? 'Total Events: ${friend.upcomingEvents}'
                                  : 'No Events',
                              style: TextStyle(
                                fontSize: 14,
                                color: friend.upcomingEvents > 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios,
                                color: Colors.teal),
                            onTap: () => _navigateToFriendGifts(friend),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: BounceButton(
        onTap: () { print('Bounce Button Pressed!'); },
        child: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AddFriendDialog(
                userId: widget.userId,
                onAdd: (Friend newFriend) async {
                  setState(() {
                    if (!friends.any(
                        (friend) => friend.firebaseId == newFriend.firebaseId)) {
                      friends.add(newFriend); // Add the new friend to the list
                    }
                  });
                  print('Friend added: ${newFriend.toMap()}');
                  await _fetchFriends(); // Refresh the friends list
                },
              ),
            );
          },
          child: const Icon(Icons.person_add),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }
}
