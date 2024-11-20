import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  bool notificationsEnabled = true;
  File? _profileImage; // Store the selected image
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> createdEvents = [
    {
      'name': 'Birthday Party',
      'date': DateTime(2024, 11, 15),
      'gifts': [
        {'name': 'Smartwatch', 'isPledged': true},
        {'name': 'Gift Card', 'isPledged': false},
      ],
    },
    {
      'name': 'Conference',
      'date': DateTime(2024, 11, 5),
      'gifts': [
        {'name': 'Notebook', 'isPledged': true},
      ],
    },
  ];

  void _showEditProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Save changes to profile
                Navigator.of(context).pop();
                // You may want to save the updated information here
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _toggleNotifications(bool? value) {
    setState(() {
      notificationsEnabled = value ?? true;
    });
  }

  void _navigateToPledgedGifts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PledgedGiftsPage()),
    );
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image Container
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : AssetImage('assets/default_profile.png') as ImageProvider, // Placeholder image
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 30, color: Colors.white) // Camera icon if no image
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Profile Information
            Text('Profile Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ListTile(
              title: Text('Name: ${nameController.text.isEmpty ? "Not Set" : nameController.text}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditProfileDialog,
              ),
            ),
            ListTile(
              title: Text('Email: ${emailController.text.isEmpty ? "Not Set" : emailController.text}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: _showEditProfileDialog,
              ),
            ),
            SizedBox(height: 20),

            // Notification Settings
            Text('Notification Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: Text('Enable Notifications'),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SizedBox(height: 20),

            // Created Events
            Text('Created Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: createdEvents.length,
                itemBuilder: (context, index) {
                  final event = createdEvents[index];
                  return ListTile(
                    title: Text(event['name']),
                    subtitle: Text('Date: ${event['date'].toLocal()}'),
                    onTap: () {
                      // Navigate to the event details page (implement this if needed)
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 10),

            // Link to Pledged Gifts Page
            ElevatedButton(
              onPressed: _navigateToPledgedGifts,
              child: Text('View My Pledged Gifts'),
            ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for PledgedGiftsPage
class PledgedGiftsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: Center(
        child: Text('List of pledged gifts will be shown here.'),
      ),
    );
  }
}