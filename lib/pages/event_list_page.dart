// lib/pages/event_list_page.dart
import 'package:flutter/material.dart';
import '../models/gift.dart'; // Adjust the import path as needed

class EventGiftDetailsPage extends StatelessWidget {
  final Gift gift;

  EventGiftDetailsPage({required this.gift});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(gift.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${gift.name}', style: TextStyle(fontSize: 18)),
            Text('Category: ${gift.category}', style: TextStyle(fontSize: 16)),
            Text('Status: ${gift.status}', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
