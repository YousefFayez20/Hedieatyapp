import 'package:flutter/material.dart';
import '../models/event.dart';

class AddEventDialog extends StatefulWidget {
  final Event? event;
  final Function(Event) onAdd;

  AddEventDialog({required this.onAdd, this.event});

  @override
  _AddEventDialogState createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<AddEventDialog> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController dateController;
  DateTime? selectedDate;
  String status = 'Upcoming';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.event?.name ?? '');
    categoryController = TextEditingController(text: widget.event?.category ?? '');
    selectedDate = widget.event?.date ?? DateTime.now();
    status = widget.event?.status ?? 'Upcoming';
    dateController = TextEditingController(text: selectedDate!.toLocal().toString().split(' ')[0]);
  }

  void _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate!,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
        dateController.text = selectedDate!.toLocal().toString().split(' ')[0];
      });
    }
  }

  void _saveEvent() {
    if (nameController.text.isEmpty || categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    Event newEvent = Event(
      id: widget.event?.id ?? DateTime.now().toString(),
      name: nameController.text,
      date: selectedDate!,
      location: widget.event?.location ?? 'Default location',
      description: widget.event?.description ?? 'No description',
      userId: widget.event?.userId ?? 'Default User ID',
      category: categoryController.text,
      status: status,
    );
    widget.onAdd(newEvent);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Event Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: InputDecoration(labelText: 'Category'),
            ),
            GestureDetector(
              onTap: _pickDate,
              child: AbsorbPointer(
                child: TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: 'Date (YYYY-MM-DD)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: status,
              onChanged: (String? newValue) {
                setState(() {
                  status = newValue!;
                });
              },
              items: <String>['Upcoming', 'Current', 'Past'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Status'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: _saveEvent,
          child: Text(widget.event == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
