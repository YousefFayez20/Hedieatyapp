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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final giftsData = await _databaseHelper.fetchGiftsByFriendGroupedByEvent(widget.friendId);
      final friend = await _databaseHelper.fetchFriendById(widget.friendId);

      setState(() {
        groupedGifts = giftsData;
        friendName = friend?.name ?? 'Unknown Friend';
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(String dateString) {
    try {
      DateTime dateTime = DateTime.parse(dateString);
      return "${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')}/${dateTime.year}";
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$friendName\'s Gifts'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : groupedGifts.isEmpty
          ? const Center(
        child: Text('No gifts or events found for this friend.',
            style: TextStyle(fontSize: 16, color: Colors.grey)),
      )
          : ListView.builder(
        itemCount: groupedGifts.length,
        itemBuilder: (context, index) {
          final event = groupedGifts[index];
          final eventDate = _formatDate(event['event_date']);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 3,
            child: ExpansionTile(
              leading: Icon(Icons.event, color: Colors.teal),
              title: Text(
                '${event['event_name']} - $eventDate',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Status: ${event['event_status']}',
                style: const TextStyle(color: Colors.grey),
              ),
              children: event['gifts'].isEmpty
                  ? [
                const ListTile(
                  title: Text('No gifts for this event.'),
                )
              ]
                  : (event['gifts'] as List).map<Widget>((gift) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  leading: CircleAvatar(
                    backgroundColor: gift['gift_status'] == 'Pledged'
                        ? Colors.green
                        : Colors.orangeAccent,
                    child: Icon(
                      gift['gift_status'] == 'Pledged'
                          ? Icons.check_circle
                          : Icons.card_giftcard,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    gift['gift_name'],
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${gift['gift_category']} - \$${gift['gift_price']}',
                          style: const TextStyle(color: Colors.grey)),
                      Text(
                        'Status: ${gift['gift_status']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: gift['gift_status'] == 'Pledged'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
