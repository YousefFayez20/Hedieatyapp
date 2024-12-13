import 'package:flutter/material.dart';
import '../models/friend.dart';
import '../utils/firestore_service.dart';
import '../utils/database_helper.dart';

class AddFriendDialog extends StatefulWidget {
  final Function(Friend) onAdd;
  final int userId;

  const AddFriendDialog({Key? key, required this.onAdd, required this.userId})
      : super(key: key);

  @override
  _AddFriendDialogState createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  final _nameController = TextEditingController();
  String? _selectedProfileImage;
  final _formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveFriend() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = await _dbHelper.getEmailByUserId(widget.userId);

    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not found.')),
      );
      return;
    }

    final newFriend = Friend(
      id: null,
      name: _nameController.text.trim(),
      profileImage: _selectedProfileImage ?? 'assets/default_profile.png',
      upcomingEvents: 0,
      userId: widget.userId,
    );

    try {
      await _firestoreService.addFriendToFirestore(newFriend, email);
      widget.onAdd(newFriend);
      Navigator.of(context).pop();
    } catch (error) {
      print('Error adding friend: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to add friend.')),
      );
    }
  }

  Widget _buildImageSelector() {
    final assetImages = [
      'assets/man_2.png',
      'assets/man_1.png',
      'assets/girl_1.png',
      'assets/girl_2.png'
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: assetImages.length,
      itemBuilder: (context, index) {
        final imagePath = assetImages[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedProfileImage = imagePath;
            });
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                imagePath,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
              ),
              if (_selectedProfileImage == imagePath)
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green, width: 3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.check_circle, color: Colors.green),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      title: const Text('Add a Friend'),
      content: Container(
        width: screenSize.width * 0.8, // Use 80% of the screen width
        child: SingleChildScrollView(
          child: Form(
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
                const SizedBox(height: 16),
                const Text(
                  'Select a Profile Picture:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildImageSelector(),
              ],
            ),
          ),
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
