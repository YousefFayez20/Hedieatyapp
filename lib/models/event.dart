// models/event.dart
class Event {
  final String name;
  final DateTime date;
  final String category;
  final String status; // "Upcoming", "Current", "Past"

  Event({required this.name, required this.date, required this.category, required this.status});
}
