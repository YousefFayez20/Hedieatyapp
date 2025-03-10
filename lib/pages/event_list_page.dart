import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import 'package:trial15/models/event.dart';
import '../models/friend.dart';
import '../utils/firestore_service.dart';
import '../utils/bounce_button.dart';
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

  bool _isSyncing = false;
  Future<void> _syncAndFetchEvents() async {
    setState(() {
      _isLoading = true;
    });
    if (_isSyncing) return;
    _isSyncing = true;

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
        _isSyncing = false;
      });
    }
  }
  Future<void> _onRefresh() async {
    // Logic to refresh the events (fetch new data from Firestore or local DB)
    await _syncAndFetchEvents();
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
                await _databaseHelper.insertEvent(newEvent);
                print("Event inserted: ${newEvent.name}");
              } else {
                final firebaseId = await _firestoreService.addEventToFirestore(newEvent, email);
                final updatedEvent = newEvent.copyWith(firebaseId: firebaseId);
                await _databaseHelper.insertEvent(updatedEvent);
                print("Event added with Firestore ID: $firebaseId");
              }
              print("Attempting to insert event: ${newEvent.name}");

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
    final event = await _databaseHelper.fetchEventById(id);
    if (event == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event not found.')),
      );
      return;
    }

    if (event.friendId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete personal events.')),
      );
      return;
    }

    final email = await _databaseHelper.getEmailByUserId(event.userId);
    if (email != null && event.firebaseId != null) {
      await FirestoreService().deleteEventFromFirestore(event.firebaseId!, email);
    } else {
      print('Skipping Firestore deletion as firebaseId is null');
    }

    await _databaseHelper.deleteEvent(id);
    _syncAndFetchEvents();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event deleted successfully.')),
    );
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
            onPressed: () async {
              Navigator.pop(context);
              await _deleteEvent(id);
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
      body: RefreshIndicator(
        onRefresh: _syncAndFetchEvents, // Trigger the refresh logic
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _events.isEmpty
            ? ListView(
          // Ensure it's scrollable to trigger RefreshIndicator
          children: const [
            SizedBox(
              height: 400, // Placeholder height for empty state
              child: Center(
                child: Text('No events available.'),
              ),
            ),
          ],
        )
            : ListView.builder(
          key: Key('event_list'),
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
      ),
      floatingActionButton: BounceButton(
        onTap: () {   print('Bounce Button Pressed!');},
        child: FloatingActionButton(
          onPressed: () => _addOrEditEvent(null),
          tooltip: 'Add Event',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

}
