import 'package:flutter/material.dart';
import '../utils/database_helper.dart';
import '../models/gift.dart';
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
  List<Gift> _gifts = [];
  String _sortColumn = 'name';
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    _fetchGifts();
  }

  Future<void> _fetchGifts() async {
    final gifts = await _databaseHelper.fetchGiftsByEventId(widget.eventId);
    setState(() {
      _gifts = gifts;
    });
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
          eventId: widget.eventId, // Pass the eventId for gift association
        ),
      ),
    );

    if (result == true) {
      _fetchGifts(); // Refresh the gift list after adding or editing
    }
  }

  Future<void> _deleteGift(int id) async {
    await _databaseHelper.deleteGift(id);
    _fetchGifts();
  }

  void _confirmDelete(int id) {
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
              _deleteGift(id);
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
            onPressed: () => _addOrEditGift(gift), // Navigate to GiftEditPage
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(gift.id!),
          ),
        ],
      ),
      onTap: () => _addOrEditGift(gift), // Navigate to GiftEditPage
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gifts for ${widget.eventName}'),
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