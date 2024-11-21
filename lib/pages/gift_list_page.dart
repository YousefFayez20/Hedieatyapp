import 'package:flutter/material.dart';
import '../models/gift.dart';  // Ensure the path matches your project structure
import '../models/event.dart';
import 'gift_details_page.dart';

class GiftListPage extends StatefulWidget {
  final Event event;

  GiftListPage({required this.event});

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  List<Gift> gifts = [];

  @override
  void initState() {
    super.initState();
    // Initialize with dummy data relevant to the passed event
    gifts = fetchGiftsForEvent(widget.event);
  }

  List<Gift> fetchGiftsForEvent(Event event) {
    // Here you can define gifts specific to each event if necessary
    return [
      Gift(name: 'Bluetooth Speaker', description: 'High quality sound', category: 'Electronics', price: 150.0, status: 'Available', isPledged: false),
      Gift(name: 'Leather Wallet', description: 'Genuine leather wallet', category: 'Accessories', price: 49.99, status: 'Pledged', isPledged: true),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.event.name}'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: Gift.empty())),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            title: Text(gift.name),
            subtitle: Text('${gift.category} - \$${gift.price.toStringAsFixed(2)}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: gift.isPledged ? null : () => _deleteGift(index),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: gift)),
            ),
          );
        },
      ),
    );
  }

  void _deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }
}
