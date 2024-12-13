class Gift {
  final int? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String status;
  final int? eventId; // Nullable
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? giftFirebaseId; // New field

  Gift({
    this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.eventId, // Nullable
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.giftFirebaseId, // Nullable
  });

  Gift copyWith({
    int? id,
    String? name,
    String? description,
    String? category,
    double? price,
    String? status,
    int? eventId,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? giftFirebaseId,
  }) {
    return Gift(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      price: price ?? this.price,
      status: status ?? this.status,
      eventId: eventId ?? this.eventId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      giftFirebaseId: giftFirebaseId ?? this.giftFirebaseId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'status': status,
      'event_id': eventId,
      'image_url': imageUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'gift_firebase_id': giftFirebaseId, // Add to map
    };
  }

  factory Gift.fromMap(Map<String, dynamic> map) {
    return Gift(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      category: map['category'],
      price: map['price'],
      status: map['status'],
      eventId: map['event_id'],
      imageUrl: map['image_url'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      giftFirebaseId: map['gift_firebase_id'], // Parse from map
    );
  }
}
