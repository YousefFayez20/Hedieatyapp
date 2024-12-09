import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../utils/firestore_service.dart';  // Import FirestoreService
import '../utils/database_helper.dart';   // Import DatabaseHelper
class AddFriendDialog extends StatefulWidget {
  final Function(Friend) onAdd;
  final int userId; // userId is an integer passed to the dialog

  const AddFriendDialog({Key? key, required this.onAdd, required this.userId}) : super(key: key);

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _nameController = TextEditingController();
  final _profileImageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseHelper _dbHelper = DatabaseHelper();


  @override
  void dispose() {
    _nameController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  Future<void> _saveFriend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Fetch the email using the userId (which is an integer)
    final email = await DatabaseHelper().getEmailByUserId(widget.userId);

    if (email == null) {
      // If email is not found, show an error message and return
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not found.')));
      return;
    }

    final newFriend = Friend(
      id: null,
      name: _nameController.text.trim(),
      profileImage: _profileImageController.text.trim().isEmpty
          ? 'assets/default_profile.png'
          : _profileImageController.text.trim(),
      upcomingEvents: 0,
      userId: widget.userId,  // Use the email retrieved from the database
    );

    try {

      // Check if the friend already exists in the local database by firebase_id
      if (newFriend.firebaseId != null) {
        final existingFriend = await _dbHelper.fetchFriendByFirebaseId(newFriend.firebaseId!);
        // Proceed with your logic
      } else {
        print("Error: Friend's firebaseId is null.");
        // Handle the error (e.g., show a message, skip the operation)
      }

      //if (existingFriend != null) {
        // If the friend already exists, show a message and don't insert again
        //ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('This friend is already added.')));
        //return;
      //}

      // Insert the new friend into the database
      //final insertedId = await _dbHelper.insertFriend(newFriend);
      await _firestoreService.addFriendToFirestore(newFriend, email);

      // After insertion, update the friend with the inserted ID
      //final updatedFriend = newFriend.copyWith(id: insertedId);

      // Call the callback to update the UI with the new friend
      //widget.onAdd(updatedFriend);

      // Close the dialog
      Navigator.of(context).pop();
    } catch (error) {
      print('Error adding friend: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add friend.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a Friend'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Friend Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _profileImageController,
              decoration: const InputDecoration(labelText: 'Profile Image URL (optional)'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveFriend,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
