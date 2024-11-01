// pages/event_list.dart
import 'package:flutter/material.dart';
import '../models/event.dart';

class EventList extends StatelessWidget {
  final List<Event> events;

  EventList({required this.events});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return Dismissible(
          key: ValueKey(event.name),
          background: Container(color: Colors.red, child: Icon(Icons.delete, color: Colors.white)),
          onDismissed: (direction) {
            events.removeAt(index);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${event.name} deleted')),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              leading: Icon(
                Icons.event,
                color: event.status == 'Upcoming'
                    ? Colors.green
                    : event.status == 'Current'
                    ? Colors.blue
                    : Colors.grey,
              ),
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
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                // TODO: Navigate to Event Details or Edit event
              },
            ),
          ),
        );
      },
    );
  }
}

// Extension for DateTime to format date to a short string
extension DateFormat on DateTime {
  String toShortString() {
    return '${this.day}/${this.month}/${this.year}';
  }
}
