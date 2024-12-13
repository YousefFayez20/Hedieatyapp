import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/gift.dart';
import '../utils/firestore_service.dart';
import 'gift_edit_page.dart';

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

  late String _userEmail;
  late String _friendFirebaseId;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      print('Event ID passed: ${widget.eventId}');
      // Fetch event details
      final event = await _databaseHelper.fetchEventById(widget.eventId);
      if (event == null) throw Exception("Event not found");

      // Fetch user email
      final userEmail = await _databaseHelper.getEmailByUserId(event.userId);
      if (userEmail == null) throw Exception("User email not found");
      _userEmail = userEmail;

      // Fetch friend's Firebase ID
      if (event.friendId != null) {
        final friendFirebaseId = await _databaseHelper.getFirebaseIdByFriendId(event.friendId!);
        if (friendFirebaseId == null) throw Exception("Friend's Firebase ID not found");
        _friendFirebaseId = friendFirebaseId;
      } else {
        _friendFirebaseId = ""; // Personal event
      }

      // Fetch gifts
      await _fetchGifts();
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      setState(() {
        _isSyncing = false;
      });
    }
  }

  Future<void> _fetchGifts() async {
    try {
      // Fetch gifts from Firestore
      final firestoreGifts = await _firestoreService.fetchGiftsForFriendEvent(
        _userEmail,
        _friendFirebaseId,
        widget.eventId.toString(),
      );

      // Sync Firestore gifts with local database
      for (var gift in firestoreGifts) {
        final localGift = await _databaseHelper.getGiftByFirebaseId(gift.giftFirebaseId!);
        if (localGift == null) {
          await _databaseHelper.insertGift(gift);
        }
      }

      // Fetch gifts from local database
      final localGifts = await _databaseHelper.fetchGiftsByEventId(widget.eventId);
      setState(() {
        _gifts = localGifts;
      });
    } catch (e) {
      print('Error fetching gifts: $e');
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
      _fetchGifts();
    }
  }

  Future<void> _deleteGift(int id, String? firebaseId) async {
    try {
      // Delete from local database
      await _databaseHelper.deleteGift(id);

      // Delete from Firestore if firebaseId exists
      if (firebaseId != null) {
        await _firestoreService.deleteGiftFromFriendEvent(
          _userEmail,
          _friendFirebaseId,
          widget.eventId.toString(),
          firebaseId,
        );
      }

      _fetchGifts();
    } catch (e) {
      print('Error deleting gift: $e');
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
            onPressed: () {
              Navigator.pop(context);
              _deleteGift(id, firebaseId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftTile(Gift gift) {
    final isPledged = gift.status == 'Pledged';

    return ListTile(
      title: Text(
        gift.name,
        style: TextStyle(
          color: isPledged ? Colors.grey : Colors.black,
        ),
      ),
      subtitle: Text(
        'Category: ${gift.category} | Price: \$${gift.price}',
        style: TextStyle(
          color: isPledged ? Colors.grey : Colors.black,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _addOrEditGift(gift),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(gift.id!, gift.giftFirebaseId),
          ),
        ],
      ),
      onTap: () => _addOrEditGift(gift),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditGift(null),
        tooltip: 'Add Gift',
        child: const Icon(Icons.add),
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
