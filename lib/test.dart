import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class GiftPage extends StatefulWidget {
  @override
  _GiftPageState createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> gifts = [
    {
      'name': 'Smartwatch',
      'description': 'A fitness tracker and smartwatch',
      'category': 'Electronics',
      'price': 200,
      'status': 'Not Pledged',
      'isPledged': false,
      'image': null,
    },
    {
      'name': 'Book',
      'description': 'A novel by a famous author',
      'category': 'Literature',
      'price': 15,
      'status': 'Pledged',
      'isPledged': true,
      'image': null,
    },
  ];

  String _sortBy = 'name';
  int? selectedIndex;

  // Sort gifts list by selected criteria
  void _sortGifts(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      gifts.sort((a, b) => a[sortBy].compareTo(b[sortBy]));
    });
  }

  // Show dialog to add or edit a gift
  void _showGiftDialog({Map<String, dynamic>? gift, int? index}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    bool isPledged = gift?['isPledged'] ?? false;
    File? selectedImage = gift?['image'];

    if (gift != null) {
      nameController.text = gift['name'];
      descriptionController.text = gift['description'];
      categoryController.text = gift['category'];
      priceController.text = gift['price'].toString();
    }

    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          selectedImage = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(gift == null ? 'Add Gift' : 'Edit Gift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                SizedBox(height: 10),
                Row(
                  children: [
                    Text('Status: '),
                    Switch(
                      value: isPledged,
                      onChanged: !isPledged
                          ? (value) {
                        setState(() {
                          isPledged = value;
                        });
                      }
                          : null,
                    ),
                    Text(isPledged ? 'Pledged' : 'Available'),
                  ],
                ),
                if (selectedImage != null)
                  Image.file(selectedImage!, height: 100, width: 100, fit: BoxFit.cover),
                TextButton(
                  onPressed: !isPledged ? _pickImage : null,
                  child: Text('Upload Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (gift == null) {
                  // Add a new gift
                  setState(() {
                    gifts.add({
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'category': categoryController.text,
                      'price': double.tryParse(priceController.text) ?? 0,
                      'status': isPledged ? 'Pledged' : 'Available',
                      'isPledged': isPledged,
                      'image': selectedImage,
                    });
                  });
                } else {
                  // Edit an existing gift
                  setState(() {
                    gifts[index!] = {
                      'name': nameController.text,
                      'description': descriptionController.text,
                      'category': categoryController.text,
                      'price': double.tryParse(priceController.text) ?? 0,
                      'status': isPledged ? 'Pledged' : 'Available',
                      'isPledged': isPledged,
                      'image': selectedImage,
                    };
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the selected gift
  void _deleteGift() {
    if (selectedIndex != null) {
      setState(() {
        gifts.removeAt(selectedIndex!);
        selectedIndex = null; // Reset after deletion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for Event'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortGifts,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'category', child: Text('Sort by Category')),
              PopupMenuItem(value: 'status', child: Text('Sort by Status')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: gifts.length,
        itemBuilder: (context, index) {
          final gift = gifts[index];
          return ListTile(
            leading: gift['image'] != null
                ? Image.file(gift['image'], width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.card_giftcard),
            title: Text(gift['name']),
            subtitle: Text('${gift['category']} - ${gift['description']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('\$${gift['price']}'),
                Text(gift['status']),
              ],
            ),
            tileColor: gift['isPledged']
                ? Colors.greenAccent.withOpacity(0.3)
                : Colors.redAccent.withOpacity(0.3),
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            onLongPress: gift['isPledged']
                ? null // Disable editing if the gift is pledged
                : () => _showGiftDialog(gift: gift, index: index),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _showGiftDialog(),
            heroTag: 'add',
            mini: true,
            child: Icon(Icons.add),
            tooltip: 'Add Gift',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: selectedIndex != null && !gifts[selectedIndex!]['isPledged']
                ? () => _showGiftDialog(gift: gifts[selectedIndex!], index: selectedIndex)
                : null,
            heroTag: 'edit',
            mini: true,
            child: Icon(Icons.edit),
            tooltip: 'Edit Gift',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: selectedIndex != null ? _deleteGift : null,
            heroTag: 'delete',
            mini: true,
            child: Icon(Icons.delete),
            tooltip: 'Delete Gift',
          ),
        ],
      ),
    );
  }
}