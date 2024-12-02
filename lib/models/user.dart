class User {
  final int? id;
  final String name;
  final String email;
  final String password;
  final String? preferences;

  User({
    this.id,
    required this.name,
    required this.email,
    required this.password,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'preferences': preferences,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      preferences: map['preferences'],
    );
  }
}