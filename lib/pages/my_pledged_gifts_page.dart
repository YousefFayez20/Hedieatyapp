import 'package:flutter/material.dart';
import '../models/gift.dart';  // Update your path based on your project structure

class MyPledgedGiftsPage extends StatefulWidget {
  @override
  _MyPledgedGiftsPageState createState() => _MyPledgedGiftsPageState();
}

class _MyPledgedGiftsPageState extends State<MyPledgedGiftsPage> {
  List<PledgedGift> pledgedGifts = [
    PledgedGift(
      name: 'Smartwatch',
      description: 'Latest model smartwatch with health tracking features.',
      category: 'Electronics',
      price: 250.0,
      status: 'Pledged',
      dueDate: DateTime(2024, 12, 20),
      friendName: 'Alice',
    ),
    PledgedGift(
      name: 'Book',
      description: 'A novel by a famous author.',
      category: 'Literature',
      price: 15.0,
      status: 'Pledged',
      dueDate: DateTime(2024, 11, 25),
      friendName: 'Bob',
    ),
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
          final gift = pledgedGifts[index];
          return ListTile(
            title: Text(gift.name),
            subtitle: Text('Due: ${gift.dueDate.toString().split(' ')[0]} | Friend: ${gift.friendName}'),
            trailing: Icon(Icons.check, color: Colors.green),
            onTap: () {
              // Here, you could add functionality to edit or view more details about the gift
            },
          );
        },
      ),
    );
  }
}
