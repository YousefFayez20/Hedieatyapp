import 'package:flutter/material.dart';
import 'dart:io';

class GiftDetailsPage extends StatelessWidget {
  final Map<String, dynamic> gift;
  final Function(Map<String, dynamic>) onSave;

  GiftDetailsPage({required this.gift, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final TextEditingController nameController =
    TextEditingController(text: gift['name']);
    final TextEditingController descriptionController =
    TextEditingController(text: gift['description']);
    final TextEditingController categoryController =
    TextEditingController(text: gift['category']);
    final TextEditingController priceController =
    TextEditingController(text: gift['price'].toString());
    bool isPledged = gift['isPledged'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gift Name'),
              enabled: !isPledged,
            ),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description'),
              enabled: !isPledged,
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
              enabled: !isPledged,
            ),
            TextField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.number,
              enabled: !isPledged,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:'),
                Switch(
                  value: isPledged,
                  onChanged: (value) {
                    // Prevent changes if the gift is pledged
                    if (!isPledged) {
                      isPledged = value;
                    }
                  },
                ),
                Text(isPledged ? 'Pledged' : 'Available'),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                onSave({
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'price': double.parse(priceController.text),
                  'isPledged': isPledged,
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
