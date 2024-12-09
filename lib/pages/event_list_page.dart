import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/event.dart';
import '../models/friend.dart';
import 'event_edit_page.dart';
import 'add_event_page.dart';
import 'gift_list_page.dart';
import '../utils/firestore_service.dart';

class EventListPage extends StatefulWidget {
  final int userId; // Accept userId to filter events for the specific user

  const EventListPage({Key? key, required this.userId}) : super(key: key);

  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  List<Event> _events = [];
  List<Friend> _friends = []; // Store friends for the user
  String _sortColumn = 'name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final email = await _databaseHelper.getEmailByUserId(widget.userId);
    if (email == null) {
      print("Error: No email found for the given user ID");
      return;
    }

    // Fetch events for the user
    final userEvents = await _firestoreService.fetchEventsFromFirestore(widget.userId, email);

    // Fetch and add friend events separately
    final friends = await _databaseHelper.fetchAllFriends(widget.userId);
    List<Event> friendEvents = [];
    for (var friend in friends) {
      final friendEventsList = await _firestoreService.fetchFriendEventsFromFirestore(widget.userId, email, friend.firebaseId!);
      friendEvents.addAll(friendEventsList);
    }

    setState(() {
      _events = userEvents + friendEvents; // Combine both lists
      _friends = friends;
    });
  }

  Future<void> _addOrEditEvent(Event? event) async {
    if (event == null) {
      // Navigate to AddEventPage
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
                final friendfirebaseId = await _databaseHelper.getFirebaseIdByFriendId(newEvent.friendId!);
                // If the event is for a friend, add it to their event collection
                await _firestoreService.addFriendEventToFirestore(newEvent, email, friendfirebaseId!);
              } else {
                // Otherwise, add it to the user's own event collection
                await _firestoreService.addEventToFirestore(newEvent, email);
              }
              await _databaseHelper.insertEvent(newEvent);

              _fetchData();
            },
            userId: widget.userId,
            friends: _friends, // Pass the list of friends
          ),
        ),
      );

      if (result == true) {
        _fetchData();
      }
    } else {
      // Navigate to EventEditPage
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
        _fetchData();
      }
    }
  }

  Future<void> _deleteEvent(int id) async {
    await _databaseHelper.deleteEvent(id);
    _fetchData();
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
      body: _events.isEmpty
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
                  '${event.category} | ${event.status} | ${event.date.toLocal().toString().split(' ')[0]}'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GiftListPage(
                      eventId: event.id!,
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
