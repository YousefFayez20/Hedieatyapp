import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/database_helper.dart';

class NotificationCenterPage extends StatefulWidget {
  final int userId;

  const NotificationCenterPage({Key? key, required this.userId}) : super(key: key);

  @override
  _NotificationCenterPageState createState() => _NotificationCenterPageState();
}

class _NotificationCenterPageState extends State<NotificationCenterPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // Duration for the slide animation
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<String?>(
        future: DatabaseHelper().getEmailByUserId(widget.userId),
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

                  // Add animation to the notification card
                  final animation = Tween<Offset>(
                    begin: const Offset(0, -1), // Start off-screen above
                    end: Offset.zero,           // Slide into its position
                  ).animate(
                    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
                  );

                  // Start the animation
                  _controller.forward();

                  return SlideTransition(
                    position: animation,
                    child: Card(
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
