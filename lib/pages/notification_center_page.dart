import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../utils/database_helper.dart';

class NotificationCenterPage extends StatelessWidget {
  final int userId;

  const NotificationCenterPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            tooltip: 'Mark All as Read',
            onPressed: () async {
              final email = await DatabaseHelper().getEmailByUserId(userId);
              if (email != null) {
                final notifications = await FirebaseFirestore.instance
                    .collection('users')
                    .doc(email)
                    .collection('notifications')
                    .get();

                for (var doc in notifications.docs) {
                  await doc.reference.update({'isRead': true});
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read!')),
                );
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: DatabaseHelper().getEmailByUserId(userId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final email = snapshot.data!;
          return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(email)
                .collection('notifications')
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final notifications = snapshot.data!.docs;

              if (notifications.isEmpty) {
                return const Center(
                  child: Text(
                    'No notifications available.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['isRead'] as bool;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: isRead ? Colors.grey[300] : Colors.teal,
                        child: Icon(
                          isRead ? Icons.done : Icons.notifications,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        notification['message'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isRead ? Colors.grey : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        notification['timestamp'].toDate().toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          notification.reference.update({'isRead': true});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Notification marked as read')),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRead ? Colors.grey : Colors.teal,
                        ),
                        child: Text(
                          isRead ? 'Read' : 'Mark as Read',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
