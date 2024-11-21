class Gift {
  String name;
  String description;
  String category;
  double price;
  String status;  // "Available" or "Pledged"
  bool isPledged;
  String? imageUrl;

  Gift({
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.status,
    this.isPledged = false,
    this.imageUrl,
  });

  // Adding a named constructor for an empty gift
  Gift.empty()
      : name = '',
        description = '',
        category = '',
        price = 0.0,
        status = 'Available',
        isPledged = false,
        imageUrl = null;
}

class PledgedGift extends Gift {
  DateTime dueDate;
  String friendName;

  PledgedGift({
    required String name,
    required String description,
    required String category,
    required double price,
    required String status,
    bool isPledged = true,
    String? imageUrl,
    required this.dueDate,
    required this.friendName,
  }) : super(
    name: name,
    description: description,
    category: category,
    price: price,
    status: status,
    isPledged: isPledged,
    imageUrl: imageUrl,
  );

// Add methods specific to pledged gifts if necessary, such as extending or modifying the pledge
}