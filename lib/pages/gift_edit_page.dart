import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gift.dart';
import '../utils/database_helper.dart';

class GiftEditPage extends StatefulWidget {
  final Gift? gift; // Null if adding a new gift
  final int eventId; // To link the gift to a specific event

  const GiftEditPage({Key? key, this.gift, required this.eventId}) : super(key: key);

  @override
  _GiftEditPageState createState() => _GiftEditPageState();
}

class _GiftEditPageState extends State<GiftEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _databaseHelper = DatabaseHelper();

  // Fields for gift details
  late String _name;
  late String _description;
  late String _category;
  late double _price;
  late String _status;
  File? _imageFile; // File for the gift image
  final ImagePicker _picker = ImagePicker();

  bool _isPledged = false; // To track if the gift is pledged

  @override
  void initState() {
    super.initState();

    // Initialize fields with existing gift data (if editing) or default values (if adding)
    _name = widget.gift?.name ?? '';
    _description = widget.gift?.description ?? '';
    _category = widget.gift?.category ?? 'Other';
    _price = widget.gift?.price ?? 0.0;
    _status = widget.gift?.status ?? 'Available';
    _isPledged = _status == 'Pledged'; // Mark as pledged if the current status is 'Pledged'

    // Load existing image if editing
    if (widget.gift?.imageUrl != null && widget.gift!.imageUrl!.isNotEmpty) {
      _imageFile = File(widget.gift!.imageUrl!);
    }
  }

  Future<void> _pickImage() async {
    if (_isPledged) return; // Prevent changing the image if pledged

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Create a new or updated Gift object
      final gift = Gift(
        id: widget.gift?.id, // Retain ID if editing, null if adding
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        status: _status,
        eventId: widget.eventId,
        imageUrl: _imageFile?.path ?? widget.gift?.imageUrl ?? '', // Save image path
        createdAt: widget.gift?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.gift == null) {
        // Add a new gift
        await _databaseHelper.insertGift(gift);
      } else {
        // Update an existing gift
        await _databaseHelper.updateGift(gift);
      }

      Navigator.pop(context, true); // Notify parent about changes
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.gift == null ? 'Add Gift' : (_isPledged ? 'View Gift' : 'Edit Gift')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Gift Image
              Center(
                child: GestureDetector(
                  onTap: _isPledged ? null : _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : const AssetImage('assets/default_image.png') as ImageProvider,
                    child: _imageFile == null
                        ? const Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gift Name
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Gift Name *'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the gift name.';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!,
                enabled: !_isPledged, // Disable the field if pledged
              ),
              const SizedBox(height: 16.0),

              // Gift Description
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
                enabled: !_isPledged, // Disable the field if pledged
              ),
              const SizedBox(height: 16.0),

              // Gift Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Books', 'Toys', 'Clothing', 'Other']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: _isPledged
                    ? null // Disable dropdown if pledged
                    : (value) {
                  setState(() {
                    _category = value!;
                  });
                },
                onSaved: (value) => _category = value!,
              ),
              const SizedBox(height: 16.0),

              // Gift Price
              TextFormField(
                initialValue: _price > 0 ? _price.toString() : null,
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price.';
                  }
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Please enter a valid price.';
                  }
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
                enabled: !_isPledged, // Disable the field if pledged
              ),
              const SizedBox(height: 16.0),

              // Gift Status
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: _isPledged
                    ? [
                  const DropdownMenuItem(
                    value: 'Pledged',
                    child: Text('Pledged'),
                  ),
                ]
                    : [
                  const DropdownMenuItem(
                    value: 'Available',
                    child: Text('Available'),
                  ),
                  const DropdownMenuItem(
                    value: 'Pledged',
                    child: Text('Pledged'),
                  ),
                ],
                onChanged: (value) {
                  if (_isPledged) return; // Prevent changing if pledged
                  setState(() {
                    _status = value!;
                    if (_status == 'Pledged') {
                      _isPledged = true; // Lock fields when pledged
                    }
                  });
                },
                onSaved: (value) => _status = value!,
              ),
              const SizedBox(height: 32.0),

              // Save Button
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
