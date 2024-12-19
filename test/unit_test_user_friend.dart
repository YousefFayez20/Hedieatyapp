// Importing the necessary packages
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/friend.dart';

void main() {
  group('Friend Model Tests', () {
    test('Friend object creation and properties', () {
      final friend = Friend(
        id: 1,
        name: 'Jane Smith',
        profileImage: 'path/to/image.png',
        upcomingEvents: 2,
        userId: 1,
        firebaseId: 'firebase123',
      );

      expect(friend.id, 1);
      expect(friend.name, 'Jane Smith');
      expect(friend.profileImage, 'path/to/image.png');
      expect(friend.upcomingEvents, 2);
      expect(friend.userId, 1);
      expect(friend.firebaseId, 'firebase123');
    });

    test('Friend copyWith method', () {
      final friend = Friend(
        id: 1,
        name: 'Jane Smith',
        profileImage: 'path/to/image.png',
        upcomingEvents: 2,
        userId: 1,
        firebaseId: 'firebase123',
      );

      final updatedFriend = friend.copyWith(name: 'Jane Doe', upcomingEvents: 3);

      expect(updatedFriend.name, 'Jane Doe');
      expect(updatedFriend.upcomingEvents, 3);
      expect(updatedFriend.profileImage, 'path/to/image.png'); // Unchanged
    });

    test('Friend toMap and fromMap', () {
      final friend = Friend(
        id: 1,
        name: 'Jane Smith',
        profileImage: 'path/to/image.png',
        upcomingEvents: 2,
        userId: 1,
        firebaseId: 'firebase123',
      );

      final map = friend.toMap();
      final recreatedFriend = Friend.fromMap(map);

      expect(recreatedFriend.id, friend.id);
      expect(recreatedFriend.name, friend.name);
      expect(recreatedFriend.profileImage, friend.profileImage);
      expect(recreatedFriend.upcomingEvents, friend.upcomingEvents);
      expect(recreatedFriend.userId, friend.userId);
      expect(recreatedFriend.firebaseId, friend.firebaseId);
    });
  });
}
