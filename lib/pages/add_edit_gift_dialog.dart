import 'package:flutter/material.dart';

class EventPage extends StatefulWidget {
  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  List<Map<String, dynamic>> events = [
    {
      'name': 'Birthday Party',
      'category': 'Personal',
      'status': 'Upcoming',
      'date': DateTime(2024, 11, 15),
    },
    {
      'name': 'Conference',
      'category': 'Work',
      'status': 'Current',
      'date': DateTime(2024, 11, 5),
    },
    {
      'name': 'Graduation Ceremony',
      'category': 'Academic',
      'status': 'Past',
      'date': DateTime(2024, 6, 10),
    },
  ];

  String _sortBy = 'name';
  int? selectedIndex;

  void _sortEvents(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      events.sort((a, b) {
        if (sortBy == 'date') {
          return a[sortBy].compareTo(b[sortBy]);
        } else {
          return a[sortBy].compareTo(b[sortBy]);
        }
      });
    });
  }

  void _showEventDialog({Map<String, dynamic>? event, int? index}) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController categoryController = TextEditingController();
    final TextEditingController dateController = TextEditingController();

    if (event != null) {
      nameController.text = event['name'];
      categoryController.text = event['category'];
      dateController.text = event['date'].toLocal().toString().split(' ')[0]; // Display date as YYYY-MM-DD
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event == null ? 'Add Event' : 'Edit Event'),
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
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(labelText: 'Date (YYYY-MM-DD)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (event == null) {
                  // Add a new event
                  setState(() {
                    events.add({
                      'name': nameController.text,
                      'category': categoryController.text,
                      'status': _getEventStatus(DateTime.parse(dateController.text)),
                      'date': DateTime.parse(dateController.text),
                    });
                  });
                } else {
                  // Edit an existing event
                  setState(() {
                    events[index!] = {
                      'name': nameController.text,
                      'category': categoryController.text,
                      'status': _getEventStatus(DateTime.parse(dateController.text)),
                      'date': DateTime.parse(dateController.text),
                    };
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _getEventStatus(DateTime date) {
    final now = DateTime.now();
    if (date.isAfter(now)) {
      return 'Upcoming';
    } else if (date.isBefore(now) && date.isAfter(now.subtract(Duration(days: 1)))) {
      return 'Current';
    } else {
      return 'Past';
    }
  }

  void _deleteEvent() {
    if (selectedIndex != null) {
      setState(() {
        events.removeAt(selectedIndex!);
        selectedIndex = null; // Reset after deletion
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _sortEvents,
            itemBuilder: (context) => [
              PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              PopupMenuItem(value: 'category', child: Text('Sort by Category')),
              PopupMenuItem(value: 'date', child: Text('Sort by Date')),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event['name']),
            subtitle: Text('${event['category']} - ${event['status']} - ${event['date'].toLocal()}'),
            onTap: () {
              selectedIndex = index;
              _showEventDialog(event: event, index: index);
            },
            onLongPress: () {
              setState(() {
                selectedIndex = index;
              });
            },
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _showEventDialog(),
            heroTag: 'add',
            mini: true,
            child: Icon(Icons.add),
            tooltip: 'Add Event',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: selectedIndex != null ? () => _showEventDialog(event: events[selectedIndex!], index: selectedIndex) : null,
            heroTag: 'edit',
            mini: true,
            child: Icon(Icons.edit),
            tooltip: 'Edit Event',
          ),
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: selectedIndex != null ? _deleteEvent : null,
            heroTag: 'delete',
            mini: true,
            child: Icon(Icons.delete),
            tooltip: 'Delete Event',
          ),
        ],
      ),
    );
  }
}