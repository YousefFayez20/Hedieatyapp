import 'package:flutter/material.dart';
import '../models/gift.dart';

class GiftDetailsPage extends StatefulWidget {
  final Gift gift;

  GiftDetailsPage({required this.gift});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  late TextEditingController nameController;
  late TextEditingController descriptionController;
  late TextEditingController categoryController;
  late TextEditingController priceController;
  late TextEditingController statusController;
  late bool isPledged;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.gift.name);
    descriptionController = TextEditingController(text: widget.gift.description);
    categoryController = TextEditingController(text: widget.gift.category);
    priceController = TextEditingController(text: widget.gift.price.toString());
    statusController = TextEditingController(text: widget.gift.status);
    isPledged = widget.gift.isPledged;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Gift Name', border: OutlineInputBorder()),
              enabled: !isPledged,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              enabled: !isPledged,
              maxLines: 3,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              enabled: !isPledged,
            ),
            SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: !isPledged,
            ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: statusController.text,
              decoration: InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
              items: ['Available', 'Pledged'].map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: !isPledged ? (value) {
                setState(() {
                  statusController.text = value!;
                });
              } : null,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: !isPledged ? () {
                // Save changes logic
                print('Changes saved');
              } : null,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
