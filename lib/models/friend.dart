class Friend {
  final int? id;
  final String name;
  final String profileImage;
  int upcomingEvents;
  final int? userId; // Indicates the user ID who owns this friend
  String? firebaseId; // Nullable Firebase ID for syncing with Firestore

  Friend({
    this.id,
    required this.name,
    required this.profileImage,
    this.upcomingEvents = 0,
    this.userId,
    this.firebaseId,
  });

  // Convert Friend to a Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'profile_image': profileImage,
      'upcoming_events': upcomingEvents,
      'user_id': userId,
      'firebase_id': firebaseId, // Save Firebase ID to database
    };
  }

  // Create Friend from a Map
  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      name: map['name'],
      profileImage: map['profile_image'],
      upcomingEvents: map['upcoming_events'] ?? 0,
      userId: map['user_id'],
      firebaseId: map['firebase_id'], // Retrieve Firebase ID from database
    );
  }

  // Add a copyWith method for creating modified copies of a Friend
  Friend copyWith({
    int? id,
    String? name,
    String? profileImage,
    int? upcomingEvents,
    int? userId,
    String? firebaseId, // Allow copying the Firebase ID
  }) {
    return Friend(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImage: profileImage ?? this.profileImage,
      upcomingEvents: upcomingEvents ?? this.upcomingEvents,
      userId: userId ?? this.userId,
      firebaseId: firebaseId ?? this.firebaseId, // Use the updated Firebase ID if provided
    );
  }
}
