import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gift.dart';
import '../utils/database_helper.dart';
import 'dart:io';

class GiftDetailsPage extends StatefulWidget {
  final Gift? gift;

  const GiftDetailsPage({Key? key, this.gift}) : super(key: key);

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  String _name = '';
  String _description = '';
  String _category = 'Others'; // Default category
  double _price = 0.0;
  String _status = 'available'; // Default status
  File? _imageFile;

  final List<String> _categories = ['Electronics', 'Books', 'Toys', 'Clothing', 'Others'];
  final List<String> _statuses = ['available', 'pledged'];

  @override
  void initState() {
    super.initState();
    if (widget.gift != null) {
      _name = widget.gift!.name;
      _description = widget.gift!.description;
      _category = widget.gift!.category;
      _price = widget.gift!.price;
      _status = widget.gift!.status;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveGift() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final gift = Gift(
        id: widget.gift?.id,
        name: _name,
        description: _description,
        category: _category,
        price: _price,
        status: _status,
        eventId: widget.gift?.eventId ?? 0, // Default eventId if null
        imageUrl: _imageFile?.path ?? widget.gift?.imageUrl ?? '',
        createdAt: widget.gift?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.gift == null) {
        await _databaseHelper.insertGift(gift);
      } else {
        await _databaseHelper.updateGift(gift);
      }

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPledged = _status == 'pledged';

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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
                enabled: !isPledged,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
                enabled: !isPledged,
              ),
              DropdownButtonFormField<String>(
                value: _categories.contains(_category) ? _category : 'Others', // Fallback to valid value
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((category) {
                  return DropdownMenuItem(value: category, child: Text(category));
                }).toList(),
                onChanged: isPledged ? null : (value) => setState(() => _category = value!),
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              TextFormField(
                initialValue: _price > 0 ? _price.toString() : null,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) return 'Please enter a valid price';
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
                enabled: !isPledged,
              ),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _statuses.contains(_status) ? _status : 'available', // Fallback to valid value
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: _statuses.map((status) {
                        return DropdownMenuItem(value: status, child: Text(status));
                      }).toList(),
                      onChanged: isPledged ? null : (value) => setState(() => _status = value!),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Image'),
                  ),
                ],
              ),
              if (_imageFile != null || (widget.gift?.imageUrl != null && widget.gift!.imageUrl!.isNotEmpty))
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, height: 200, fit: BoxFit.cover)
                      : widget.gift?.imageUrl != null
                      ? Image.file(File(widget.gift!.imageUrl!), height: 200, fit: BoxFit.cover)
                      : const SizedBox(),
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isPledged ? null : _saveGift,
                child: Text(widget.gift == null ? 'Add Gift' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
