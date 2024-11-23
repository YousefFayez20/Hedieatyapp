import 'package:flutter/material.dart';
import '../models/gift.dart'; // Update your path based on your project structure

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  // Replace PledgedGift with Gift and add additional properties as needed
  List<Map<String, dynamic>> pledgedGifts = [
    {
      'gift': Gift(
        id: 1,
        name: 'Smartwatch',
        description: 'Latest model smartwatch with health tracking features.',
        category: 'Electronics',
        price: 250.0,
        status: 'Pledged',
        eventId: null,
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      'dueDate': DateTime(2024, 12, 20),
      'friendName': 'Alice',
    },
    {
      'gift': Gift(
        id: 2,
        name: 'Book',
        description: 'A novel by a famous author.',
        category: 'Literature',
        price: 15.0,
        status: 'Pledged',
        eventId: null,
        imageUrl: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      'dueDate': DateTime(2024, 11, 25),
      'friendName': 'Bob',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Pledged Gifts'),
      ),
      body: ListView.builder(
        itemCount: pledgedGifts.length,
        itemBuilder: (context, index) {
          final gift = pledgedGifts[index]['gift'] as Gift;
          final dueDate = pledgedGifts[index]['dueDate'] as DateTime;
          final friendName = pledgedGifts[index]['friendName'] as String;

          return ListTile(
            title: Text(gift.name),
            subtitle: Text('Due: ${dueDate.toString().split(' ')[0]} | Friend: $friendName'),
            trailing: Icon(Icons.check, color: Colors.green),
            onTap: () {
              // Add functionality for viewing/editing the pledged gift details
            },
          );
        },
      ),
    );
  }
}
