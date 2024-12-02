import 'package:flutter/material.dart';
import '../models/friend.dart';
import 'add_friend_dialog.dart';
import 'friend_gift_list_page.dart';
import 'add_event_page.dart';
import '../models/event.dart';
import '../utils/database_helper.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage({Key? key, required this.userId}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Friend> friends = [];
  String searchQuery = '';
  String sortOption = 'Total Events';

  @override
  void initState() {
    super.initState();
    _fetchFriends();
  }

  // Fetch all friends and calculate the total number of events dynamically
  Future<void> _fetchFriends() async {
    try {
      final fetchedFriends = await _databaseHelper.fetchAllFriends(widget.userId);

      // For each friend, fetch the total count of events
      for (var friend in fetchedFriends) {
        final eventCount = await _databaseHelper.fetchTotalEventCountByFriendId(friend.id!);
        friend.upcomingEvents = eventCount;  // Use the same field for total events
      }

      setState(() {
        friends = fetchedFriends;
      });

      print('Fetched friends: ${friends.map((friend) => friend.toMap()).toList()}');
    } catch (error) {
      print('Error fetching friends: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch friends.')),
      );
    }
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEventPage(
          onAdd: (Event event) async {
            try {
              await _databaseHelper.insertEvent(event);
              print('Event added: ${event.toMap()}');
              await _fetchFriends(); // Refresh after adding an event
            } catch (error) {
              print('Error adding event: $error');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to add event.')),
              );
            }
          },
          userId: widget.userId,
          friends: friends, // Pass the friends list
        ),
      ),
    );
  }

  void _navigateToFriendGifts(Friend friend) {
    if (friend.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This friend does not have a valid ID.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendGiftListPage(friendId: friend.id!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Friend> filteredFriends = friends
        .where((friend) => friend.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends & Events'),
        backgroundColor: Colors.teal,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
                if (value == 'Alphabetically') {
                  friends.sort((a, b) => a.name.compareTo(b.name));
                } else if (value == 'Total Events') {
                  friends.sort((a, b) => b.upcomingEvents.compareTo(a.upcomingEvents));
                }
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Total Events', 'Alphabetically'].map((String choice) {
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _navigateToCreateEvent,
              child: const Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredFriends.isEmpty
                ? const Center(
              child: Text(
                'No friends found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : RefreshIndicator(
              onRefresh: _fetchFriends,
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundImage: friend.profileImage.isNotEmpty
                            ? AssetImage(friend.profileImage)
                            : const AssetImage('assets/default_profile.png'),
                      ),
                      title: Text(
                        friend.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                      subtitle: Text(
                        friend.upcomingEvents > 0
                            ? 'Total Events: ${friend.upcomingEvents}'
                            : 'No Events',
                        style: TextStyle(
                          fontSize: 14,
                          color: friend.upcomingEvents > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
                      onTap: () => _navigateToFriendGifts(friend),
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
            builder: (context) => AddFriendDialog(
              userId: widget.userId,
              onAdd: (Friend newFriend) async {
                setState(() {
                  friends.add(newFriend);
                });
                print('Friend added: ${newFriend.toMap()}');
              },
            ),
          );
        },
        child: const Icon(Icons.person_add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}