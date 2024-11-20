import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic> gift;
  final Function(Map<String, dynamic>) onSave;

  GiftDetailsPage({required this.gift, required this.onSave});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  File? _image;
  bool isPledged = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    final gift = widget.gift;
    nameController.text = gift['name'];
    descriptionController.text = gift['description'];
    categoryController.text = gift['category'];
    priceController.text = gift['price'].toString();
    isPledged = gift['isPledged'];
  }

  void _saveGift() {
    if (nameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        categoryController.text.isEmpty ||
        priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All fields are required!')),
      );
      return;
    }
    widget.onSave({
      'name': nameController.text,
      'description': descriptionController.text,
      'category': categoryController.text,
      'price': double.parse(priceController.text),
      'isPledged': isPledged,
      'image': _image,
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gift Details'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
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
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Status:'),
                Switch(
                  value: isPledged,
                  onChanged: (value) {
                    if (!isPledged) {
                      setState(() {
                        isPledged = value;
                      });
                    }
                  },
                ),
                Text(isPledged ? 'Pledged' : 'Available'),
              ],
            ),
            if (_image != null)
              Image.file(_image!, height: 100, width: 100, fit: BoxFit.cover),
            TextButton(
              onPressed: !isPledged ? _pickImage : null,
              child: Text('Upload Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveGift,
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
