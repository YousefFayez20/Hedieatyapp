import 'package:flutter/material.dart';
import '../models/friend.dart';
import 'add_friend_dialog.dart';
import 'friend_gift_list_page.dart';
import 'add_event_page.dart';
import '../models/event.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Friend> friends = [
    Friend(name: 'Alice', profileImage: 'images/alice.png', upcomingEvents: 1),
    Friend(name: 'Bob', profileImage: 'images/bob.png', upcomingEvents: 2),
    Friend(name: 'Charlie', profileImage: 'images/charlie.png', upcomingEvents: 0),
  ];

  String searchQuery = '';
  String sortOption = 'Upcoming Events';

  Future<void> _refreshFriends() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {}); // Simulate refreshing the list
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(onAdd: (Event event) {
          // Placeholder for adding events
          print("Event added: ${event.name}");
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Filter the friends list based on search query
    List<Friend> filteredFriends = friends
        .where((friend) => friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Friends & Events'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Upcoming Events', 'Alphabetically'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          // Create Your Own Event/List Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _navigateToCreateEvent,
              child: Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          // Friends List
          Expanded(
            child: filteredFriends.isEmpty
                ? Center(
              child: Text(
                'No friends found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : RefreshIndicator(
              onRefresh: _refreshFriends,
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FriendGiftListPage(
                              friendName: friend.name,
                              upcomingEvents: friend.upcomingEvents,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AddFriendDialog(),
          );
        },
        child: Icon(Icons.person_add),
      ),
    );
  }
}
