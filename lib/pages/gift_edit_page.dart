import 'package:flutter/material.dart';
import '../models/gift.dart';
import '../utils/database_helper.dart';

class GiftEditPage extends StatefulWidget {
  final Gift? gift; // Null if adding a new gift
  final int eventId; // To link the gift to a specific event

  const GiftEditPage({Key? key, this.gift, required this.eventId})
      : super(key: key);

  @override
  _GiftEditPageState createState() => _GiftEditPageState();
}

class _GiftEditPageState extends State<GiftEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper();

  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late String _status;

  @override
  void initState() {
    super.initState();

    // Initialize with existing gift data or default values
    _name = widget.gift?.name ?? '';
    _description = widget.gift?.description ?? '';
    _category = widget.gift?.category ?? '';
    _price = widget.gift?.price ?? 0.0;
    _status = widget.gift?.status ?? 'Available';
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newGift = Gift(
        id: widget.gift?.id, // If editing, retain the existing ID
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        status: _status,
        eventId: widget.eventId,
        imageUrl: '', // Optional: Add logic for handling images if required
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.gift == null) {
        // Adding a new gift
        await _databaseHelper.insertGift(newGift);
      } else {
        // Editing an existing gift
        await _databaseHelper.updateGift(newGift);
      }

      // Return to the previous page with a success result
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Gift Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                onSaved: (value) {
                  _category = value ?? '';
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
                onSaved: (value) {
                  _price = double.parse(value!);
                },
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Available', 'Pledged']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Status'),
                onSaved: (value) {
                  _status = value!;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveGift,
                child: Text(widget.gift == null ? 'Add Gift' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
