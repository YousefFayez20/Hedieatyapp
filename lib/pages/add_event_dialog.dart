// pages/add_event_dialog.dart
import 'package:flutter/material.dart';
import 'package:trial15/pages/event_list.dart';
import '../models/event.dart';

class AddEventDialog extends StatefulWidget {
  final Function(Event) onAdd;
  final Event? event;

  AddEventDialog({required this.onAdd, this.event});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  String _selectedStatus = 'Upcoming';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _categoryController.text = widget.event!.category;
      _selectedStatus = widget.event!.status;
      _selectedDate = widget.event!.date;
    }
  }

  void _addEvent() {
    if (_nameController.text.isEmpty || _categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    final newEvent = Event(
      name: _nameController.text,
      date: _selectedDate,
      category: _categoryController.text,
      status: _selectedStatus,
    );
    widget.onAdd(newEvent);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Event Name'),
          ),
          TextField(
            controller: _categoryController,
            decoration: InputDecoration(labelText: 'Category'),
          ),
          DropdownButtonFormField<String>(
            value: _selectedStatus,
            items: ['Upcoming', 'Current', 'Past'].map((String status) {
              return DropdownMenuItem<String>(
                value: status,
                child: Text(status),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedStatus = value!;
              });
            },
            decoration: InputDecoration(labelText: 'Status'),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Date: ${_selectedDate.toLocal().toShortString()}'),
              Spacer(),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: _pickDate,
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addEvent,
          child: Text(widget.event == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
