import 'gift.dart'; // Ensure this import is correct

class Event {
  final String id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final String userId;
  final String category;
  final String status;
  List<Gift> gifts; // Add this to hold gifts for each event

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.category,
    required this.status,
    this.gifts = const [], // Default to an empty list of gifts
  });
}
