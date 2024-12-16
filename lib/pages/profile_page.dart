import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../utils/database_helper.dart';
import '../models/user.dart';
import '../utils/firestore_service.dart';
import 'gift_list_page.dart';  // Page for showing user's created event's gifts.
import 'my_pledged_gifts_page.dart';
import 'notification_center_page.dart';  // Page for showing the pledged gifts.

class UserProfilePage extends StatefulWidget {
  final int userId; // Accept userId to fetch and update profile data

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool notificationsEnabled = true; // Placeholder for notification setting
  User? _user; // Store the fetched user object
  List<Map<String, dynamic>> _userEvents = []; // To store personal events only
  final FirestoreService _firestoreService = FirestoreService();
  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadUserEvents(); // Load user's personal events
  }

  // Load user profile information
  Future<void> _loadUserProfile() async {
    final user = await _databaseHelper.getUserById(widget.userId);
    _setupNotificationListener(user!.email);
    if (user != null) {
      setState(() {
        _user = user;
        nameController.text = user.name;
        emailController.text = user.email;
        notificationsEnabled = user.preferences?.contains('notifications') ?? true;
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
  // Load personal events created by the user (events where friend_id is null)
  Future<void> _loadUserEvents() async {
    final events = await _databaseHelper.fetchPersonalEvents(widget.userId);

    // Convert the List<Event> into a List<Map<String, dynamic>> for display
    setState(() {
      _userEvents = events.map((event) {
        return {
          'id': event.id,
          'name': event.name,
          'date': event.date,
          'location': event.location,
          'description': event.description,
          // Add other necessary fields here
        };
      }).toList();
    });
  }

  // Update the user profile information
  Future<void> _updateUserProfile() async {
    if (_user != null) {
      final updatedUser = User(
        id: _user?.id,
        name: nameController.text,
        email: emailController.text,
        password: _user?.password ?? "", // Retain old password if unchanged
        preferences: notificationsEnabled ? 'notifications' : '',
      );
      await _databaseHelper.updateUser(updatedUser);
      setState(() {
        _user = updatedUser;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Show the edit profile dialog to update name and email
  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _updateUserProfile();
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Build event list tile to show personal events with associated gifts
  Widget _buildEventTile(Map<String, dynamic> event) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(event['name']),
        subtitle: Text('Date: ${event['date']}'),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            // Navigate to the gift list page for this event
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GiftListPage(
                  eventId: event['id'], // Pass eventId to load gifts for the event
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
            // Profile Information (Without profile image)
            const Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ListTile(
              title: Text('Name: ${nameController.text.isEmpty ? "Not Set" : nameController.text}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditProfileDialog,
              ),
            ),
            ListTile(
              title: Text('Email: ${emailController.text.isEmpty ? "Not Set" : emailController.text}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: _showEditProfileDialog,
              ),
            ),
            const SizedBox(height: 20),

            // Notification Settings
            const Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
                _updateUserProfile();
              },
            ),
            const SizedBox(height: 20),

            // User's Created Personal Events (Only personal events)
            const Text('Your Created Personal Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _userEvents.length,
                itemBuilder: (context, index) {
                  final event = _userEvents[index];
                  return _buildEventTile(event);
                },
              ),
            ),
            const SizedBox(height: 20),

            // Link to Pledged Gifts Page
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