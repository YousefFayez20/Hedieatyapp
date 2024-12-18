import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/gift.dart';
import '../utils/firestore_service.dart';
import 'gift_edit_page.dart';
import 'notification_center_page.dart';
import '../utils/bounce_button.dart';
class GiftListPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  const GiftListPage({
    Key? key,
    required this.eventId,
    required this.eventName,
  }) : super(key: key);

  @override
  _GiftListPageState createState() => _GiftListPageState();
}

class _GiftListPageState extends State<GiftListPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final FirestoreService _firestoreService = FirestoreService();
  List<Gift> _gifts = [];
  String _sortColumn = 'name';
  bool _isAscending = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncGiftsFromFirestore();
  }
  void _setupNotificationListener(String email) {
    _firestoreService.listenForNotifications(email, (message) async {
      // Show a SnackBar for in-app notification
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationCenterPage( userId: event!.userId),
                ),
              );
            },
          ),
        ),
      );
    });
  }
  Future<void> _syncGiftsFromFirestore() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) {
        throw Exception("Event not found in the local database.");
      }

      final email = await _databaseHelper.getEmailByUserId(event.userId);
      if (email == null) {
        throw Exception("User email not found for the event.");
      }
      _setupNotificationListener(email);
      final eventFirebaseId = event.firebaseId;
      if (eventFirebaseId == null || eventFirebaseId.isEmpty) {
        throw Exception("Firebase ID for the event is missing.");
      }

      if (event.friendId != null) {
        // Sync gifts for friend's event
        final friendFirebaseId =
        await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
        if (friendFirebaseId == null) {
          throw Exception("Friend Firebase ID is missing for the event.");
        }

        await _firestoreService.syncGiftsForFriendEventWithFirestore(
          event.userId,
          email,
          friendFirebaseId,
          eventFirebaseId,
          widget.eventId,
        );
      } else {
        // Sync gifts for personal event
        final firestoreGifts = await _firestoreService.fetchGiftsForPersonalEvent(
          email,
          eventFirebaseId,
        );

        for (var gift in firestoreGifts) {
          gift = gift.copyWith(eventId: widget.eventId);
          final localGift = await _databaseHelper.getGiftByFirebaseId(gift.giftFirebaseId!);

          if (localGift == null) {
            await _databaseHelper.insertGift(gift);
          }
        }
      }

      final localGifts = await _databaseHelper.fetchGiftsByEventId(widget.eventId);
      setState(() {
        _gifts = localGifts;
      });
    } catch (e) {
      print("Error syncing gifts: $e");
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  void _sortGifts(String column) {
    setState(() {
      if (_sortColumn == column) {
        _isAscending = !_isAscending;
      } else {
        _sortColumn = column;
        _isAscending = true;
      }

      _gifts.sort((a, b) {
        final compare = _compareColumn(a, b, column);
        return _isAscending ? compare : -compare;
      });
    });
  }

  int _compareColumn(Gift a, Gift b, String column) {
    switch (column) {
      case 'category':
        return a.category.compareTo(b.category);
      case 'status':
        return a.status.compareTo(b.status);
      case 'name':
      default:
        return a.name.compareTo(b.name);
    }
  }

  Future<void> _addOrEditGift(Gift? gift) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftEditPage(
          gift: gift,
          eventId: widget.eventId,
        ),
      ),
    );

    if (result == true) {
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) {
        print("Error: Event not found.");
        return;
      }

      final email = await _databaseHelper.getEmailByUserId(event.userId);
      if (email == null) {
        print("Error: User email not found.");
        return;
      }

      if (gift == null) {
        // Adding a new gift
        try {
          final addedGift = await _databaseHelper.insertAndReturnGift(result);
          await _firestoreService.addGiftToPersonalEvent(
            email,
            event.firebaseId!,
            addedGift,
          );
        } catch (e) {
          print("Error adding gift: $e");
        }
      } else {
        // Editing an existing gift (handled elsewhere in FirestoreService)
        print("Gift edited. Syncing handled elsewhere.");
      }

      _syncGiftsFromFirestore();
    }
  }
  void _confirmDelete(int id, String? firebaseId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Gift'),
        content: const Text('Are you sure you want to delete this gift?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteGift(id, firebaseId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  Future<void> _deleteGift(int id, String? firebaseId) async {
    try {
      print("Starting deletion process for gift with local ID: $id, Firebase ID: $firebaseId");

      // Delete from the local database
      await _databaseHelper.deleteGift(id);
      print("Successfully deleted gift locally with ID: $id");

      if (firebaseId != null) {
        final event = await _databaseHelper.fetchEventById(widget.eventId);
        if (event == null) throw Exception("Event not found for local ID: ${widget.eventId}");

        final email = await _databaseHelper.getEmailByUserId(event.userId);
        if (email == null) throw Exception("User email not found for user ID: ${event.userId}");

        if (event.friendId != null) {
          final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
          if (friendFirebaseId == null) throw Exception("Friend Firebase ID not found for friend ID: ${event.friendId}");

          print("Attempting to delete gift from Firestore for friend's event...");
          await _firestoreService.deleteGiftFromFriendEvent(
            email,
            friendFirebaseId,
            event.firebaseId!,
            firebaseId,
          );
        } else {
          print("Attempting to delete gift from Firestore for personal event...");
          await _firestoreService.deleteGiftFromPersonalEvent(
            email,
            event.firebaseId!,
            firebaseId,
          );
        }

        print("Successfully deleted gift from Firestore with Firebase ID: $firebaseId");
      }

      // Refresh the UI
      print("Refreshing gifts list...");
      _syncGiftsFromFirestore();
    } catch (e) {
      print("Error deleting gift: $e");
    }
  }


  Color _getGiftStatusColor(String status) {
    switch (status) {
      case 'Pledged':
        return Colors.green;
      case 'Purchased':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }
  Widget _buildGiftTile(Gift gift) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: gift.imageUrl != null && gift.imageUrl!.isNotEmpty
              ? Image.asset(
            gift.imageUrl!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          )
              : const Icon(Icons.card_giftcard, size: 60), // Fallback icon
        ),
        title: Text(
          gift.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category: ${gift.category}'),
            Text('Price: \$${gift.price.toStringAsFixed(2)}'),
            Text(
              'Status: ${gift.status}',
              style: TextStyle(color: _getGiftStatusColor(gift.status)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: gift.status == 'Pledged'
                  ? null // Disable edit for pledged gifts
                  : () => _addOrEditGift(gift),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: gift.status == 'Pledged'
                  ? null // Disable delete for pledged gifts
                  : () => _confirmDelete(gift.id!, gift.giftFirebaseId),
            ),
          ],
        ),
        onTap: gift.status == 'Pledged'
            ? null // Disable navigation for pledged gifts
            : () => _addOrEditGift(gift),
      ),
    );
  }



  Future<void> _updateGiftStatus(Gift gift, String newStatus) async {
    try {
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) throw Exception("Event not found.");

      final email = await _databaseHelper.getEmailByUserId(event.userId);
      if (email == null) throw Exception("User email not found.");

      if (gift.giftFirebaseId != null) {
        // Determine whether it's a personal or friend event
        if (event.friendId != null) {
          final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
          if (friendFirebaseId == null) {
            throw Exception("Friend Firebase ID is missing.");
          }

          // Update status for friend's event
          await _firestoreService.updateGiftStatus(
            email,
            event.firebaseId!,
            gift.giftFirebaseId!,
            newStatus,
            friendFirebaseId: friendFirebaseId,
          );
        } else {
          // Update status for personal event
          await _firestoreService.updateGiftStatus(
            email,
            event.firebaseId!,
            gift.giftFirebaseId!,
            newStatus,
          );
        }

        // Update the gift locally
        final updatedGift = gift.copyWith(status: newStatus);
        await _databaseHelper.updateGift(updatedGift);

        // Refresh the UI
        setState(() {
          final index = _gifts.indexWhere((g) => g.id == gift.id);
          if (index != -1) {
            _gifts[index] = updatedGift;
          }
        });

        print('Gift status updated to $newStatus.');
      }
    } catch (e) {
      print('Error updating gift status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.eventName}'),
        actions: [
          if (_isSyncing)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSortOptions(),
          Expanded(
            child: _gifts.isEmpty
                ? const Center(child: Text('No gifts available for this event.'))
                : ListView.builder(
              itemCount: _gifts.length,
              itemBuilder: (context, index) {
                final gift = _gifts[index];
                return _buildGiftTile(gift);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: BounceButton(
        onTap: () { print('bounce button pressed'); },
        child: FloatingActionButton(
          onPressed: () => _addOrEditGift(null),
          tooltip: 'Add Gift',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSortOptions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSortButton('name', 'Name'),
          _buildSortButton('category', 'Category'),
          _buildSortButton('status', 'Status'),
        ],
      ),
    );
  }

  Widget _buildSortButton(String column, String label) {
    return TextButton.icon(
      onPressed: () => _sortGifts(column),
      icon: Icon(
        _sortColumn == column
            ? (_isAscending ? Icons.arrow_upward : Icons.arrow_downward)
            : Icons.swap_vert,
      ),
      label: Text(label),
    );
  }

}
