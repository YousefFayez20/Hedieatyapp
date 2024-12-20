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
  String? _selectedAssetImage;

  bool _isPledged = false; // To track if the gift is pledged
  String? _userEmail;
  String? _friendFirebaseId;
  String? _eventFirebaseId;
  final List<String> _assetImages = [
    'assets/gift_1.png',
    'assets/gift_2.png',
    'assets/gift_3.png',
    'assets/gift_4.png',
    'assets/gift_5.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      print("Event Fetched: $event");

      if (event == null) throw Exception("Event not found");

      final userEmail = await _databaseHelper.getEmailByUserId(event.userId);
      if (userEmail == null) throw Exception("User email not found");
      _userEmail = userEmail;
      print("User Email: $_userEmail");

      if (event.firebaseId == null || event.firebaseId!.isEmpty) {
        throw Exception("Event Firebase ID not found for event ${event.id}");
      }
      _eventFirebaseId = event.firebaseId!;
      print("Event Firebase ID: $_eventFirebaseId");

      if (event.friendId != null) {
        _friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!) ?? '';
        print("Friend Firebase ID: $_friendFirebaseId");
      } else {
        _friendFirebaseId = '';
      }

      if (widget.gift != null) {
        _name = widget.gift!.name;
        _description = widget.gift!.description;
        _category = widget.gift!.category;
        _price = widget.gift!.price;
        _status = widget.gift!.status;
        print("Gift Status on Init: $_status");
        _isPledged = _status == 'Pledged';
        print("Is Pledged: $_isPledged");

        _selectedAssetImage = widget.gift!.imageUrl;
      }
    } catch (e) {
      print("Error initializing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data. Please try again.')),
      );
    }
  }


  void _pickImage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select an Image'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _assetImages.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: Image.asset(_assetImages[index], width: 50, height: 50),
                title: Text('Image ${index + 1}'),
                onTap: () {
                  setState(() {
                    _selectedAssetImage = _assetImages[index];
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
  Future<void> _saveGift() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    print("Gift Status Before Save: $_status");
    print("Is Pledged Before Save: $_isPledged");

    final gift = Gift(
      id: widget.gift?.id,
      name: _name.isEmpty ? widget.gift?.name ?? '' : _name,
      description: _description.isEmpty ? widget.gift?.description ?? '' : _description,
      category: _category,
      price: _price > 0 ? _price : widget.gift?.price ?? 0,
      status: _status,
      eventId: widget.eventId,
      imageUrl: _selectedAssetImage ?? widget.gift?.imageUrl ?? '',
      createdAt: widget.gift?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
      giftFirebaseId: widget.gift?.giftFirebaseId,
    );

    try {
      // Fetch event details
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) throw Exception("Event not found");

      // Fetch user email
      final email = await _databaseHelper.getEmailByUserId(event.userId);
      if (email == null) throw Exception("User email not found");

      // Check if gift already exists
      if (gift.giftFirebaseId != null) {
        // Update existing gift
        if (event.friendId != null) {
          final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
          if (friendFirebaseId == null || friendFirebaseId.isEmpty) {
            throw Exception("Friend Firebase ID is missing");
          }

          await _firestoreService.updateGiftDetails(
            email,
            _eventFirebaseId!,
            gift.giftFirebaseId!,
            gift,
            friendFirebaseId: friendFirebaseId,
          );
        } else {
          await _firestoreService.updateGiftDetails(
            email,
            _eventFirebaseId!,
            gift.giftFirebaseId!,
            gift,
          );
        }

        await _databaseHelper.updateGift(gift);
        print("Gift updated successfully.");
      } else {
        // Add new gift
        String firebaseGiftId;
        if (event.friendId != null) {
          final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
          if (friendFirebaseId == null || friendFirebaseId.isEmpty) {
            throw Exception("Friend Firebase ID is missing");
          }

          firebaseGiftId = await _firestoreService.addGiftToFriendEvent(
            email,
            friendFirebaseId,
            _eventFirebaseId!,
            gift,
          );
        } else {
          firebaseGiftId = await _firestoreService.addGiftToPersonalEvent(
            email,
            _eventFirebaseId!,
            gift,
          );
        }

        final newGift = gift.copyWith(giftFirebaseId: firebaseGiftId);
        await _databaseHelper.insertGift(newGift);
        print("Gift added successfully.");
      }

      // Add notification for pledged gifts
      if (_status == 'Pledged') {
        await _firestoreService.addNotification(
          email,
          'You pledged to buy ${gift.name} for ${event.name}',
          'pledge',
        );
        print("Notification added for pledged gift.");
      }

      Navigator.pop(context, true);
    } catch (e) {
      print("Error saving gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save gift. Please try again.')),
      );
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
                    backgroundImage: _selectedAssetImage != null
                        ? AssetImage(_selectedAssetImage!) as ImageProvider
                        : const AssetImage('assets/gift_1 .png'),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Gift Name
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Gift Name *'),
                validator: (value) => _isPledged || (value != null && value.isNotEmpty)
                    ? null
                    : 'Please enter a name.',
                onSaved: (value) => _name = value ?? '',
                enabled: !_isPledged, // Disable editing for pledged gifts
              ),


              const SizedBox(height: 16),

              // Gift Description
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (value) => _description = value ?? '',
                enabled: !_isPledged, // Disable editing for pledged gifts
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
                  if (_isPledged) return null; // Skip validation for pledged gifts
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed <= 0) return 'Please enter a valid price.';
                  return null;
                },
                onSaved: (value) => _price = double.tryParse(value ?? '0') ?? 0,
                enabled: !_isPledged, // Disable editing for pledged gifts
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
                  const DropdownMenuItem(
                    value: 'Purchased',
                    child: Text('Purchased'),
                  ),
                ],
                onChanged: (value) {
                  if (_isPledged) return; // Prevent changing status if pledged
                  setState(() {
                    _status = value!;
                    if (_status == 'Pledged') {
                      _isPledged = true; // Lock fields if pledged
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
