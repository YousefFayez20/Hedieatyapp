// pages/friend_list.dart
import 'package:flutter/material.dart';
import '../models/friend.dart';

class FriendList extends StatelessWidget {
  final List<Friend> friends;

  FriendList({required this.friends});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: AssetImage(friend.profileImage),
            ),
            title: Text(friend.name),
            subtitle: Text(friend.upcomingEvents > 0
                ? 'Upcoming Events: ${friend.upcomingEvents}'
                : 'No Upcoming Events'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Navigate to Friend's Gift List Page
            },
          ),
        );
      },
    );
  }
}
