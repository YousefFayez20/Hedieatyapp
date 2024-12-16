import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/event.dart';
import '../models/friend.dart';
import '../utils/firestore_service.dart';
import 'event_edit_page.dart';
import 'add_event_page.dart';
import 'gift_list_page.dart';
import 'notification_center_page.dart';

class EventListPage extends StatefulWidget {
  final int userId;

  const EventListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _events = [];
  List<Friend> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _syncAndFetchEvents();
  }

  Future<void> _syncAndFetchEvents() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final email = await _databaseHelper.getEmailByUserId(widget.userId);
      if (email == null) {
        throw Exception("User email not found for ID ${widget.userId}");
      }

      // Sync personal events from Firestore to SQLite
      await _firestoreService.syncEventsWithFirestore(widget.userId, email);

      // Fetch all friends for this user
      final friends = await _databaseHelper.fetchAllFriends(widget.userId);
      _setupNotificationListener(email);
      // Sync friend events for each friend
      for (var friend in friends) {
        if (friend.firebaseId != null) {
          await _firestoreService.syncFriendEventsWithFirestore(
            widget.userId,
            email,
            friend.firebaseId!,
          );
        }
      }

      // Fetch all events from local database
      final personalEvents = await _databaseHelper.fetchEventsForUser(widget.userId, friendId: null);
      List<Event> friendEvents = [];
      for (var friend in friends) {
        final eventsForFriend = await _databaseHelper.fetchEventsByFriendId(friend.id!);
        friendEvents.addAll(eventsForFriend);
      }

      setState(() {
        _events = personalEvents + friendEvents;
        _friends = friends;
      });
    } catch (e) {
      print('Error syncing or fetching events: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  void _setupNotificationListener(String email) {
    _firestoreService.listenForNotifications(email, (message) async {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationCenterPage(userId:  widget.userId),
                ),
              );
            },
          ),
        ),
      );
    });
  }
  Future<void> _addOrEditEvent(Event? event) async {
    if (event == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AddEventPage(
            onAdd: (newEvent) async {
              final email = await _databaseHelper.getEmailByUserId(widget.userId);
              if (email == null) {
                print("Error: No email found for the given user ID");
                return;
              }
              if (newEvent.friendId != null) {
                final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(newEvent.friendId!);
                await _firestoreService.addFriendEventToFirestore(
                  newEvent,
                  email,
                  friendFirebaseId!,
                );
              } else {
                await _firestoreService.addEventToFirestore(newEvent, email);
              }
              await _databaseHelper.insertEvent(newEvent);

              _syncAndFetchEvents();
            },
            userId: widget.userId,
            friends: _friends,
          ),
        ),
      );

      if (result == true) {
        _syncAndFetchEvents();
      }
    } else {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventEditPage(
            event: event,
            userId: widget.userId,
          ),
        ),
      );

      if (result == true) {
        _syncAndFetchEvents();
      }
    }
  }

  Future<void> _deleteEvent(int id) async {
    await _databaseHelper.deleteEvent(id);
    _syncAndFetchEvents();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _events.isEmpty
          ? const Center(child: Text('No events available.'))
          : ListView.builder(
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(event.name),
              subtitle: Text(
                '${event.category} | ${event.status} | ${event.date.toLocal().toString().split(' ')[0]}',
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(
                      eventId: event.id ?? 0,
                      eventName: event.name,
                    ),
                  ),
                );
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _addOrEditEvent(event),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _confirmDelete(event.id!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvent(null),
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }
}
