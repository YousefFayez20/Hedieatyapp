class Event {
  final int? id;  // Local database ID (SQLite)
  final String name;
  final DateTime date;
  final String location;
  final String description;
  final int userId;
  final int? friendId;  // Nullable for personal events
  final String category;
  final String status;
  final String? firebaseId;  // Nullable Firebase ID for the event (optional)

  Event({
    this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    this.friendId,  // Nullable for personal events
    required this.category,
    required this.status,
    this.firebaseId,  // Nullable Firebase ID
  });

  // Convert Event object to map (for storing in SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'user_id': userId,
      'friend_id': friendId,  // Nullable friendId
      'category': category,
      'status': status,
      'firebase_id': firebaseId,  // Nullable Firebase ID
    };
  }

  // Convert map from SQLite to Event object
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      userId: map['user_id'],
      friendId: map['friend_id'],  // Nullable
      category: map['category'],
      status: map['status'],
      firebaseId: map['firebase_id'],  // Nullable Firebase ID
    );
  }
}
