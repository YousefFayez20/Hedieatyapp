// lib/pages/add_edit_gift_dialog.dart
import 'package:flutter/material.dart';
import '../models/gift.dart';

class AddEditGiftDialog extends StatefulWidget {
  final Gift? gift;
  final int eventId;

  AddEditGiftDialog({this.gift, required this.eventId});

  @override
  _AddEditGiftDialogState createState() => _AddEditGiftDialogState();
}

class _AddEditGiftDialogState extends State<AddEditGiftDialog> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.gift?.name ?? '');
    _categoryController = TextEditingController(text: widget.gift?.category ?? '');
    _priceController = TextEditingController(
      text: widget.gift?.price.toString() ?? '',
    );
  }

  void _saveGift() {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    final now = DateTime.now();

    final newGift = Gift(
      id: widget.gift?.id,
      name: _nameController.text,
      description: widget.gift?.description ?? '',
      category: _categoryController.text,
      price: double.tryParse(_priceController.text) ?? 0.0,
      status: widget.gift?.status ?? 'Available',
      eventId: widget.eventId,
      imageUrl: widget.gift?.imageUrl,
      createdAt: widget.gift?.createdAt ?? now,
      updatedAt: now,
    );

    Navigator.of(context).pop(newGift);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gift == null ? 'Add Gift' : 'Edit Gift'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _priceController,
              decoration: InputDecoration(labelText: 'Price'),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: Text('Save'),
          onPressed: _saveGift,
        ),
      ],
    );
  }
}
