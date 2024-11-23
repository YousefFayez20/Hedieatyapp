import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/event.dart';
import 'event_edit_page.dart';
import 'gift_list_page.dart';

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Event> _events = [];
  String _sortColumn = 'name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final events = await _databaseHelper.fetchAllEvents();
    setState(() {
      _events = events;
    });
  }

  void _sortEvents(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }

      _events.sort((a, b) {
        final compare = _compareColumn(a, b, column);
        return _isAscending ? compare : -compare;
      });
    });
  }

  int _compareColumn(Event a, Event b, String column) {
    switch (column) {
      case 'category':
        return a.category.compareTo(b.category);
      case 'status':
        return a.status.compareTo(b.status);
      case 'name':
      default:
        return a.name.compareTo(b.name);
    }
  }

  Future<void> _addOrEditEvent(Event? event) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventEditPage(event: event),
      ),
    );

    if (result == true) {
      _fetchEvents();
    }
  }

  Future<void> _deleteEvent(int id) async {
    await _databaseHelper.deleteEvent(id);
    _fetchEvents();
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event List'),
      ),
      body: _events.isEmpty
          ? const Center(child: Text('No events available.'))
          : Column(
        children: [
          _buildSortOptions(),
          Expanded(
            child: ListView.builder(
              itemCount: _events.length,
              itemBuilder: (context, index) {
                final event = _events[index];
                return ListTile(
                  title: Text(event.name),
                  subtitle: Text(
                      '${event.category} | ${event.status} | ${event.date.toLocal()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GiftListPage(
                          eventId: event.id!,
                          eventName: event.name,
                        ),
                      ),
                    );
                  },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _addOrEditEvent(event),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(event.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditEvent(null),
        tooltip: 'Add Event',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSortButton('name', 'Name'),
          _buildSortButton('category', 'Category'),
          _buildSortButton('status', 'Status'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String column, String label) {
    return TextButton.icon(
      onPressed: () => _sortEvents(column),
      icon: Icon(
        _sortColumn == column
            ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.swap_vert,
      ),
      label: Text(label),
    );
  }
}
