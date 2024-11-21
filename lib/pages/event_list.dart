import 'package:flutter/material.dart';
import '../models/event.dart'; // Make sure this path matches the location of your Event model
import 'add_event_page.dart';
import 'gift_list_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  List<Event> events = [
    Event(
      id: '1',
      name: 'Community Clean Up',
      date: DateTime.now().add(const Duration(days: 30)),
      location: 'Central Park',
      description: 'Join us to clean up our community park!',
      userId: 'user001',
      category: 'Community',
      status: 'Upcoming',
    ),
    Event(
      id: '2',
      name: 'Tech Conference 2024',
      date: DateTime.now().add(const Duration(days: 60)),
      location: 'Tech Arena',
      description: 'A gathering of tech enthusiasts and professionals.',
      userId: 'user002',
      category: 'Technology',
      status: 'Upcoming',
    ),
  ];

  void _addEvent(Event event) {
    setState(() {
      events.add(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Events'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEventPage(onAdd: _addEvent),
                ),
              );
            },
          )
        ],
      ),
      body: events.isEmpty
          ? Center(child: Text('No events added yet.'))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final Event event = events[index];
          return ListTile(
            title: Text(event.name),
            subtitle: Text('${event.category} - ${event.date.toLocal().toString().split(' ')[0]}'),
            trailing: Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GiftListPage(event: event),
                ),
              );
            },
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
