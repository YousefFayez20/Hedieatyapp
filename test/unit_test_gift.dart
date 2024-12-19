// Importing the necessary packages
import 'package:flutter_test/flutter_test.dart';
import '../lib/models/gift.dart';

void main() {
  // Grouping related tests for the Gift class
  group('Gift Model Tests', () {
    test('Gift object creation and properties', () {
      // Creating a gift object
      final gift = Gift(
        id: 1,
        name: 'Test Gift',
        description: 'A gift for testing',
        category: 'Electronics',
        price: 99.99,
        status: 'Available',
        eventId: 1,
        createdAt: DateTime.parse('2023-12-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-12-01T12:00:00Z'),
      );

      // Assertions
      expect(gift.id, 1);
      expect(gift.name, 'Test Gift');
      expect(gift.description, 'A gift for testing');
      expect(gift.category, 'Electronics');
      expect(gift.price, 99.99);
      expect(gift.status, 'Available');
      expect(gift.eventId, 1);
      expect(gift.createdAt, DateTime.parse('2023-12-01T12:00:00Z'));
      expect(gift.updatedAt, DateTime.parse('2023-12-01T12:00:00Z'));
    });

    test('Copy with updated values', () {
      // Original gift object
      final originalGift = Gift(
        id: 1,
        name: 'Original Gift',
        description: 'Initial description',
        category: 'Books',
        price: 20.0,
        status: 'Available',
        eventId: 1,
        createdAt: DateTime.parse('2023-12-01T12:00:00Z'),
        updatedAt: DateTime.parse('2023-12-01T12:00:00Z'),
      );

      // Copying with updated values
      final updatedGift = originalGift.copyWith(
        name: 'Updated Gift',
        price: 25.0,
      );

      // Assertions
      expect(updatedGift.name, 'Updated Gift');
      expect(updatedGift.price, 25.0);
      expect(updatedGift.category, 'Books'); // Unchanged
    });
  });
}
