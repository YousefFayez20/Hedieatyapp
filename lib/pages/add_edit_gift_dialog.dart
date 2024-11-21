import 'package:flutter/material.dart';
import '../models/gift.dart';

class AddEditGiftDialog extends StatefulWidget {
  final Gift gift;

  AddEditGiftDialog({required this.gift});

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
    _nameController = TextEditingController(text: widget.gift.name);
    _categoryController = TextEditingController(text: widget.gift.category);
    _priceController = TextEditingController(text: widget.gift.price.toString());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.gift.name.isEmpty ? 'Add New Gift' : 'Edit Gift'),
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
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              Navigator.of(context).pop(
                Gift(
                  name: _nameController.text,
                  category: _categoryController.text,
                  price: double.tryParse(_priceController.text) ?? 0,
                  status: 'Available', // Assume the default status is "Available"
                  isPledged: false, // Default is not pledged
                  description: '', // Assuming no description field in this dialog
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
