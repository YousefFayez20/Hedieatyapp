import 'package:flutter/material.dart';

class MyPledgedGiftsPage extends StatelessWidget {
  final List<Map<String, dynamic>> pledgedGifts = [
    {'name': 'Smartwatch', 'dueDate': DateTime(2024, 12, 20), 'friend': 'Alice'},
    {'name': 'Book', 'dueDate': DateTime(2024, 11, 25), 'friend': 'Bob'},
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
            title: Text(gift['name']),
            subtitle: Text('Due: ${gift['dueDate']} | Friend: ${gift['friend']}'),
            trailing: Icon(Icons.check, color: Colors.green),
          );
        },
      ),
    );
  }
}
