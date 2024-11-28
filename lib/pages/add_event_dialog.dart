import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/friend.dart';
import '../utils/database_helper.dart';

class AddEventDialog extends StatefulWidget {
  final int userId;
  final List<Friend> friends; // List of friends to select from
  final Function() onEventAdded; // Callback to refresh event list

  const AddEventDialog({
    Key? key,
    required this.userId,
    required this.friends,
    required this.onEventAdded,
  }) : super(key: key);

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  String _name = '';
  DateTime _date = DateTime.now();
  String _location = '';
  String _description = '';
  String _category = '';
  String _status = 'Upcoming';
  int? _selectedFriendId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Event'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (value) =>
                (value == null || value.isEmpty) ? 'Please enter an event name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Location'),
                onSaved: (value) => _location = value ?? '',
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value ?? '',
              ),
              DropdownButtonFormField<String>(
                value: _category,
                items: [
                  DropdownMenuItem(value: 'Birthday', child: const Text('Birthday')),
                  DropdownMenuItem(value: 'Wedding', child: const Text('Wedding')),
                  DropdownMenuItem(value: 'Holiday', child: const Text('Holiday')),
                  DropdownMenuItem(value: 'Other', child: const Text('Other')),
                ],
                onChanged: (value) => setState(() => _category = value ?? ''),
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              DropdownButtonFormField<int?>(
                value: _selectedFriendId,
                items: [
                  DropdownMenuItem(value: null, child: const Text('Personal Event')),
                  ...widget.friends.map(
                        (friend) => DropdownMenuItem(
                      value: friend.id,
                      child: Text(friend.name),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedFriendId = value),
                decoration: const InputDecoration(labelText: 'Assign to Friend'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _pickDate(context),
                child: Text('Select Date: ${_date.toLocal()}'.split(' ')[0]),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _date) {
      setState(() => _date = picked);
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final event = Event(
        id: null,
        name: _name,
        description: _description,
        date: _date,
        location: _location,
        category: _category,
        userId: widget.userId,
        friendId: _selectedFriendId,
        status: _status,
      );

      await _databaseHelper.insertEvent(event);
      widget.onEventAdded();
      Navigator.pop(context);
    }
  }
}
