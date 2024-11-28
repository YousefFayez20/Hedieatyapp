import 'package:flutter/material.dart';
import '../models/event.dart';
import '../utils/database_helper.dart';

class EventEditPage extends StatefulWidget {
  final Event? event; // Existing event to edit (or null for adding a new event)
  final int userId;

  const EventEditPage({Key? key, this.event, required this.userId}) : super(key: key);

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  final _formKey = GlobalKey<FormState>();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _statusController;
  late TextEditingController _descriptionController;
  late TextEditingController _locationController;
  late DateTime _eventDate;

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      // Populate fields with existing event data
      _nameController = TextEditingController(text: widget.event!.name);
      _categoryController = TextEditingController(text: widget.event!.category);
      _statusController = TextEditingController(text: widget.event!.status);
      _descriptionController = TextEditingController(text: widget.event!.description);
      _locationController = TextEditingController(text: widget.event!.location);
      _eventDate = widget.event!.date;
    } else {
      // Initialize empty fields for a new event
      _nameController = TextEditingController();
      _categoryController = TextEditingController();
      _statusController = TextEditingController();
      _descriptionController = TextEditingController();
      _locationController = TextEditingController();
      _eventDate = DateTime.now();
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) {
      return; // Don't proceed if the form is invalid
    }

    // Create an updated event object
    final updatedEvent = Event(
      id: widget.event?.id, // Retain the same ID if editing
      name: _nameController.text,
      category: _categoryController.text,
      status: _statusController.text,
      description: _descriptionController.text,
      location: _locationController.text,
      date: _eventDate,
      userId: widget.userId, // Use the userId from the parent
    );

    if (widget.event == null) {
      // Add new event
      await _databaseHelper.insertEvent(updatedEvent);
    } else {
      // Update existing event
      await _databaseHelper.updateEvent(updatedEvent);
    }

    // Navigate back and refresh the parent list
    Navigator.pop(context, true);
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _eventDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter an event name' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a category' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _statusController,
                decoration: const InputDecoration(labelText: 'Status *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a status' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location *'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a location' : null,
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: Text('Date: ${_eventDate.toLocal().toShortString()}'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveEvent,
                child: Text(widget.event == null ? 'Add Event' : 'Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Extension for formatting dates
extension DateShortString on DateTime {
  String toShortString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
