import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/gift.dart';
import '../utils/database_helper.dart';
import '../utils/firestore_service.dart';

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
  final _firestoreService = FirestoreService();

  // Fields for gift details
  late String _name = '';
  late String _description = '';
  late String _category = 'Other';
  late double _price = 0.0;
  late String _status = 'Available';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isPledged = false; // To track if the gift is pledged
  String? _userEmail;
  String? _friendFirebaseId;
  String? _eventFirebaseId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      // Fetch the event from the local database
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) throw Exception("Event not found");

      // Fetch the user's email
      final userEmail = await _databaseHelper.getEmailByUserId(event.userId);
      if (userEmail == null) throw Exception("User email not found");
      _userEmail = userEmail;

      // Fetch the Firebase ID for the event
      if (event.firebaseId == null || event.firebaseId!.isEmpty) {
        throw Exception("Event Firebase ID not found for event ${event.id}");
      }
      _eventFirebaseId = event.firebaseId!;
      print("Event Firebase ID: $_eventFirebaseId");

      // Fetch the friend's Firebase ID if applicable
      if (event.friendId != null) {
        _friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!) ?? '';
        print("Friend Firebase ID: $_friendFirebaseId");
      } else {
        _friendFirebaseId = ''; // For personal events
      }

      print('Initialized Data: User Email: $_userEmail, Event Firebase ID: $_eventFirebaseId, Friend Firebase ID: $_friendFirebaseId');

      // Populate fields for editing if gift is not null
      if (widget.gift != null) {
        _name = widget.gift!.name;
        _description = widget.gift!.description;
        _category = widget.gift!.category;
        _price = widget.gift!.price;
        _status = widget.gift!.status;
        _isPledged = _status == 'Pledged';
        if (widget.gift!.imageUrl != null && widget.gift!.imageUrl!.isNotEmpty) {
          _imageFile = File(widget.gift!.imageUrl!);
        }
      }
    } catch (e) {
      print("Error initializing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data. Please try again.')),
      );
    }
  }


  Future<void> _pickImage() async {
    if (_isPledged) return;

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }
  Future<void> _saveGift() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    if (_eventFirebaseId == null || _eventFirebaseId!.isEmpty) {
      print("Error: Event Firebase ID is null or empty");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event Firebase ID is not available. Please sync the event first.')),
      );
      return;
    }

    final gift = Gift(
      id: widget.gift?.id,
      name: _name,
      description: _description,
      category: _category,
      price: _price,
      status: _status,
      eventId: widget.eventId,
      imageUrl: _imageFile?.path ?? widget.gift?.imageUrl ?? '',
      createdAt: widget.gift?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      giftFirebaseId: widget.gift?.giftFirebaseId,
    );

    try {
      if (widget.gift == null) {
        // Adding a new gift
        final firebaseGiftId = await _firestoreService.addGiftToPersonalEvent(
          _userEmail!,
          _eventFirebaseId!,
          gift,
        );

        // Assign the Firestore ID to the gift and insert it into the local database
        final insertedGift = gift.copyWith(giftFirebaseId: firebaseGiftId);
        await _databaseHelper.insertGift(insertedGift);
      } else {
        // Updating an existing gift
        await _databaseHelper.updateGift(gift);
      }
      Navigator.pop(context, true);
    } catch (e) {
      print("Error saving gift: $e");
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
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name.' : null,
                onSaved: (value) => _name = value ?? '',
                enabled: !_isPledged,
              ),
              const SizedBox(height: 16),

              // Gift Description
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
                enabled: !_isPledged,
              ),
              const SizedBox(height: 16),

              // Gift Category
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Electronics', 'Books', 'Toys', 'Clothing', 'Other']
                    .map((category) => DropdownMenuItem(value: category, child: Text(category)))
                    .toList(),
                onChanged: _isPledged ? null : (value) => setState(() => _category = value!),
                onSaved: (value) => _category = value!,
              ),
              const SizedBox(height: 16),

              // Gift Price
              TextFormField(
                initialValue: _price > 0 ? _price.toString() : '',
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Please enter a valid price.';
                  return null;
                },
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 16),

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
              const SizedBox(height: 32),

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
