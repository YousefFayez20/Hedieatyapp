import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/friend.dart';

class FriendGiftListPage extends StatefulWidget {
  final int friendId;

  const FriendGiftListPage({Key? key, required this.friendId}) : super(key: key);

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> groupedGifts = [];
  String friendName = '';
  bool _isLoading = true; // Track if data is still loading

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      print('Fetching data for friend ID: ${widget.friendId}');

      // Fetch gifts grouped by event for the specified friend
      final giftsData = await _databaseHelper.fetchGiftsByFriendGroupedByEvent(widget.friendId);

      // Fetch friend details
      final friend = await _databaseHelper.fetchFriendById(widget.friendId);

      setState(() {
        groupedGifts = giftsData;
        friendName = friend?.name ?? 'Unknown Friend';
        _isLoading = false; // Data has been fetched, hide loading
      });
    } catch (e) {
      print('Error fetching gifts or friend details: $e');
      setState(() {
        _isLoading = false; // In case of error, stop loading
      });
    }
  }

  // Simple method to format event date
  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      // Format the date as: Month Day, Year (e.g. Jan 01, 2024)
      return "${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}";
    } catch (e) {
      return dateString; // If error, return the original string
    }
  }

  // Method to handle pledging a gift
  Future<void> _pledgeGift(int giftId) async {
    // Logic to update the gift status to "Pledged"
    await _databaseHelper.updateGiftStatus(giftId, 'Pledged');
    setState(() {
      // Reload data to reflect changes
      _fetchData();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gift has been pledged successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Gifts'),
        backgroundColor: Colors.teal, // Color for the app bar
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Show progress while loading
          : groupedGifts.isEmpty
          ? const Center(child: Text('No gifts or events found for this friend.')) // Empty state message
          : ListView.builder(
        itemCount: groupedGifts.length,
        itemBuilder: (context, index) {
          final event = groupedGifts[index];
          final eventDate = _formatDate(event['event_date']);
          return ExpansionTile(
            title: Row(
              children: [
                Icon(Icons.event, color: Colors.teal), // Event icon
                const SizedBox(width: 10),
                Text(
                  '${event['event_name']} - $eventDate',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            subtitle: Text('Status: ${event['event_status']}'),
            children: event['gifts'].isEmpty
                ? [ListTile(title: Text('No gifts for this event.'))]
                : (event['gifts'] as List).map<Widget>((gift) {
              return ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                title: Text(gift['gift_name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${gift['gift_category']} - \$${gift['gift_price']}'),
                    if (gift['gift_status'] == 'Pledged')
                      Text(
                        'Status: Pledged',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                  ],
                ),
                trailing: gift['gift_status'] == 'Pledged'
                    ? Icon(Icons.check, color: Colors.green)
                    : ElevatedButton(
                  onPressed: () => _pledgeGift(gift['gift_id']),
                  child: Text('Pledge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Blue color for the button
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}