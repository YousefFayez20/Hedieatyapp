import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/user.dart';
import '../utils/firestore_service.dart';
import 'my_pledged_gifts_page.dart';
import 'gift_list_page.dart';
import 'notification_center_page.dart';

class UserProfilePage extends StatefulWidget {
  final int userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool notificationsEnabled = true;
  User? _user;
  List<Map<String, dynamic>> _userEvents = [];
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserEvents();
  }

  Future<void> _loadUserProfile() async {
    final user = await _databaseHelper.getUserById(widget.userId);
    _setupNotificationListener(user!.email);
    if (user != null) {
      setState(() {
        _user = user;
        notificationsEnabled = user.preferences?.contains('notifications') ?? true;
      });
    }
  }

  void _setupNotificationListener(String email) {
    _firestoreService.listenForNotifications(email, (message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationCenterPage(userId: widget.userId)),
              );
            },
          ),
        ),
      );
    });
  }

  Future<void> _loadUserEvents() async {
    final events = await _databaseHelper.fetchPersonalEvents(widget.userId);
    setState(() {
      _userEvents = events.map((event) {
        return {
          'id': event.id,
          'name': event.name,
          'date': event.date,
          'location': event.location,
          'description': event.description,
        };
      }).toList();
    });
  }

  Widget _buildEventTile(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(event['name']),
        subtitle: Text('Date: ${event['date']}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftListPage(
                  eventId: event['id'],
                  eventName: event['name'],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Information
            const Text(
              'Profile Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  'Name',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  _user?.name ?? 'Not Set',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(
                  'Email',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                subtitle: Text(
                  _user?.email ?? 'Not Set',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Notification Settings
            const Text(
              'Notification Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
            ),
            const SizedBox(height: 20),

            // User's Personal Events
            const Text(
              'Your Created Personal Events',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadUserEvents, // Triggers a reload of user events
                child: ListView.builder(
                  itemCount: _userEvents.length,
                  itemBuilder: (context, index) {
                    final event = _userEvents[index];
                    return _buildEventTile(event);
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Pledged Gifts Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyPledgedGiftsPage(userId: widget.userId)),
                );
              },
              child: const Text('View My Pledged Gifts'),
            ),
          ],
        ),
      ),
    );
  }
}
