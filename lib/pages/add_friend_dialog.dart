// pages/add_friend_dialog.dart
import 'package:flutter/material.dart';

class AddFriendDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Friend Name'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Phone Number'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Save friend to list
            Navigator.pop(context);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
