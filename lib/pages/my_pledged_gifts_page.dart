import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/gift.dart';
import 'gift_edit_page.dart';
class MyPledgedGiftsPage extends StatefulWidget {
  final int userId;

  const MyPledgedGiftsPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Map<String, dynamic>> pledgedGifts = [];

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    final results = await _databaseHelper.fetchPledgedGifts(widget.userId);
    setState(() {
      pledgedGifts = results;
    });
  }

  Widget _buildGiftCard(Map<String, dynamic> gift) {
    final dueDate = DateTime.parse(gift['event_date']);
    final isOverdue = dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(
          gift['gift_name'],
          style: TextStyle(
            color: isOverdue ? Colors.red : Colors.black,
          ),
        ),
        subtitle: Text(
          'Friend: ${gift['friend_name'] ?? 'No Friend Assigned'}\n'
              'Due: ${dueDate.toLocal().toString().split(' ')[0]}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'modify') {
              _modifyGift(gift);
            } else if (value == 'cancel') {
              _cancelPledge(gift);
            }
          },
          itemBuilder: (context) => [
            if (!isOverdue)
              PopupMenuItem(
                value: 'modify',
                child: const Text('Modify'),
              ),
            PopupMenuItem(
              value: 'cancel',
              child: const Text('Cancel Pledge'),
            ),
          ],
        ),
      ),
    );
  }

  void _modifyGift(Map<String, dynamic> gift) {
    // Navigate to edit page with the selected gift
  }

  void _cancelPledge(Map<String, dynamic> gift) async {
    final giftId = gift['gift_id'];

    await _databaseHelper.updateGift(
      Gift(
        id: giftId,
        name: gift['gift_name'],
        description: gift['description'] ?? '',
        category: gift['gift_category'],
        price: gift['gift_price'] ?? 0.0,
        status: 'Available', // Cancel the pledge and set status to Available
        eventId: gift['gift_event_id'],
        createdAt: DateTime.parse(gift['gift_created_at']),
        updatedAt: DateTime.now(),
      ),
    );

    _fetchPledgedGifts(); // Refresh the list after canceling the pledge
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pledged Gifts'),
      ),
      body: pledgedGifts.isEmpty
          ? const Center(child: Text('No pledged gifts found.'))
          : ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index];
          return _buildGiftCard(gift);
        },
      ),
    );
  }
}
