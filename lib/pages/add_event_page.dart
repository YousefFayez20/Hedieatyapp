import 'package:flutter/material.dart';
import '../models/event.dart';

class AddEventPage extends StatefulWidget {
  final Function(Event) onAdd;

  AddEventPage({required this.onAdd});

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _status = 'Upcoming';

  void _saveEvent() {
    if (_nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final newEvent = Event(
      id: null,
      name: _nameController.text,
      description: _descriptionController.text,
      date: _selectedDate,
      location: _locationController.text,
      category: _categoryController.text,
      userId: 'user001', // Replace with actual user context
      status: _status,
    );

    widget.onAdd(newEvent);
    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Event Name *'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category *'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location *'),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_selectedDate.toLocal().toShortString()}'),
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                value: _status,
                items: ['Upcoming', 'Current', 'Past'].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                decoration: InputDecoration(labelText: 'Status'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text('Save Event'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Date extension for formatting
extension DateShortString on DateTime {
  String toShortString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
