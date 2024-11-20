import 'package:flutter/material.dart';

class FriendGiftListPage extends StatefulWidget {
  final String friendName;
  final int upcomingEvents;

  FriendGiftListPage({required this.friendName, required this.upcomingEvents});

  @override
  _FriendGiftListPageState createState() => _FriendGiftListPageState();
}

class _FriendGiftListPageState extends State<FriendGiftListPage> {
  List<Map<String, dynamic>> gifts = [
    {'name': 'Smartwatch', 'status': 'Available', 'isPledged': false},
    {'name': 'Book', 'status': 'Pledged', 'isPledged': true},
    {'name': 'Headphones', 'status': 'Available', 'isPledged': false},
  ];

  void _pledgeGift(int index) {
    setState(() {
      gifts[index]['isPledged'] = true;
      gifts[index]['status'] = 'Pledged';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.friendName}\'s Gifts')),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            title: Text(
              gift['name'],
              style: TextStyle(
                color: gift['isPledged'] ? Colors.green : Colors.black,
              ),
            ),
            trailing: gift['isPledged']
                ? Icon(Icons.check, color: Colors.green)
                : ElevatedButton(
              onPressed: () => _pledgeGift(index),
              child: Text('Pledge'),
            ),
          );
        },
      ),
    );
  }
}
