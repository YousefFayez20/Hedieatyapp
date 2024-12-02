class Event {
  final int? id;
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final int userId;
  final int? friendId; // Nullable for personal events
  final String category;
  final String status;

  Event({
    this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    this.friendId, // Nullable for personal events
    required this.category,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'user_id': userId,
      'friend_id': friendId, // Include friendId in database mapping
      'category': category,
      'status': status,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      userId: map['user_id'],
      friendId: map['friend_id'], // Parse friendId (nullable)
      category: map['category'],
      status: map['status'],
    );
  }
}