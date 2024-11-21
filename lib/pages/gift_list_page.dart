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
    gifts = fetchGiftsForEvent(widget.event);
  }

  List<Gift> fetchGiftsForEvent(Event event) {
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
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Icon(Icons.card_giftcard, color: Theme.of(context).primaryColor),
              title: Text(gift.name, style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${gift.category} - \$${gift.price.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(gift.isPledged ? Icons.check : Icons.edit),
                color: gift.isPledged ? Colors.green : Colors.blue,
                onPressed: () {
                  if (!gift.isPledged) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: gift)),
                    );
                  }
                },
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GiftDetailsPage(gift: gift)),
              ),
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
