import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/friend.dart';

class AddEventPage extends StatefulWidget {
  final Function(Event) onAdd; // Callback to add the event
  final int userId; // ID of the current user
  final List<Friend> friends; // List of friends for assigning events

  const AddEventPage({
    Key? key,
    required this.onAdd,
    required this.userId,
    required this.friends,
  }) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  // Controllers for input fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();

  DateTime _selectedDate = DateTime.now(); // Event date
  String _status = 'Upcoming'; // Default status
  int? _selectedFriendId; // Nullable for personal or friend's events

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Event Name Input
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name *'),
              ),
              const SizedBox(height: 16),

              // Event Description Input
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Event Location Input
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              const SizedBox(height: 16),

              // Event Category Input
              TextField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              const SizedBox(height: 16),

              // Date Picker
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Friend Selection Dropdown
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
              const SizedBox(height: 16),

              // Event Status Dropdown
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Upcoming', 'Current', 'Past'].map(
                      (status) => DropdownMenuItem(
                    value: status,
                    child: Text(status),
                  ),
                ).toList(),
                onChanged: (value) => setState(() => _status = value!),
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveEvent,
                child: const Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  void _saveEvent() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event name is required.')),
      );
      return;
    }

    final newEvent = Event(
      id: null,
      name: _nameController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      category: _categoryController.text,
      date: _selectedDate,
      userId: widget.userId,
      friendId: _selectedFriendId,
      status: _status,
    );

    widget.onAdd(newEvent);
    Navigator.pop(context);
  }
}