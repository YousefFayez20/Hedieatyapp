import 'package:flutter/material.dart';
import '../models/event.dart';
import 'add_event_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final List<Event> events = [];

  void _addEvent(Event event) {
    setState(() {
      events.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: events.isEmpty
          ? Center(child: Text('No events added yet.'))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text('${event.category} - ${event.date.toLocal().toShortString()}'),
            trailing: Text(
              event.status,
              style: TextStyle(
                color: event.status == 'Upcoming'
                    ? Colors.green
                    : event.status == 'Current'
                    ? Colors.blue
                    : Colors.grey,
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEventPage(onAdd: _addEvent),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
