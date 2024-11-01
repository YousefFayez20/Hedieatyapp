// pages/event_list_page.dart
import 'package:flutter/material.dart';
import '../models/event.dart';
import 'event_list.dart';
import 'add_event_dialog.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final List<Event> events = [
    Event(name: 'Alice’s Wedding', date: DateTime(2024, 5, 20), category: 'Wedding', status: 'Upcoming'),
    Event(name: 'Bob’s Birthday', date: DateTime(2024, 1, 15), category: 'Birthday', status: 'Current'),
    Event(name: 'Charlie’s Graduation', date: DateTime(2023, 11, 12), category: 'Graduation', status: 'Past'),
  ];

  String sortOption = 'Date';

  Future<void> _refreshEvents() async {
    await Future.delayed(Duration(seconds: 1));
    setState(() {});
  }

  void _showAddEventDialog([Event? event]) {
    showDialog(
      context: context,
      builder: (context) => AddEventDialog(
        onAdd: (Event newEvent) {
          setState(() {
            events.add(newEvent);
          });
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newEvent.name} added!')),
          );
        },
        event: event,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Event> sortedEvents = List.from(events);

    if (sortOption == 'Date') {
      sortedEvents.sort((a, b) => a.date.compareTo(b.date));
    } else if (sortOption == 'Category') {
      sortedEvents.sort((a, b) => a.category.compareTo(b.category));
    } else if (sortOption == 'Status') {
      sortedEvents.sort((a, b) => a.status.compareTo(b.status));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Event List'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortOption = value;
              });
            },
            itemBuilder: (BuildContext context) {
              return ['Date', 'Category', 'Status'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: sortedEvents.isEmpty
          ? Center(child: Text('No events to display.'))
          : RefreshIndicator(
        onRefresh: _refreshEvents,
        child: EventList(events: sortedEvents),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}
