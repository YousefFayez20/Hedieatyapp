import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/gift.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'hedieaty.db');

    // Comment out deleteDatabase to ensure persistence
    // await deleteDatabase(path); // Remove this in production

    return openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete, // Optional for testing
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      date TEXT NOT NULL,
      location TEXT,
      description TEXT,
      user_id TEXT,
      category TEXT,
      status TEXT
    )
  ''');

    await db.execute('''
    CREATE TABLE gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      price REAL NOT NULL,
      status TEXT NOT NULL,
      event_id INTEGER,
      image_url TEXT,
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (event_id) REFERENCES events (id) ON DELETE CASCADE
    )
  ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3) {
      await db.execute('ALTER TABLE gifts ADD COLUMN image_url TEXT');
    }
  }

  // Event-related functions
  Future<int> insertEvent(Event event) async {
    final db = await database;
    final eventId = await db.insert('events', event.toMap());
    print('Event inserted with ID: $eventId');
    return eventId;
  }

  Future<List<Event>> fetchAllEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> rawEvents = await db.query('events');

    print('Fetched ${rawEvents.length} events from the database.');

    return rawEvents.map((eventMap) => Event.fromMap(eventMap)).toList();
  }

  Future<Event?> fetchEventById(int id) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      print('Event found: ${results.first}');
      return Event.fromMap(results.first);
    }
    print('Event with ID $id not found');
    return null;
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    final rowsUpdated = await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
    print('Updated $rowsUpdated rows for event ID: ${event.id}');
    return rowsUpdated;
  }

  Future<int> deleteEvent(int id) async {
    final db = await database;
    final rowsDeleted = await db.delete(
      'events',
      where: 'id = ?',
      whereArgs: [id],
    );
    print('Deleted $rowsDeleted rows for event ID: $id');
    return rowsDeleted;
  }

  // Gift-related functions
  Future<int> insertGift(Gift gift) async {
    final db = await database;
    print('Inserting gift: ${gift.toMap()}');
    final giftId = await db.insert('gifts', gift.toMap());
    print('Gift inserted with ID: $giftId');
    return giftId;
  }

  Future<List<Gift>> fetchGiftsByEventId(int eventId) async {
    final db = await database;
    print('Fetching gifts for event ID: $eventId');
    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    print('Fetched ${maps.length} gifts for event ID $eventId');
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  Future<List<Gift>> fetchAllGifts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('gifts');
    print('Fetched ${maps.length} total gifts');
    return maps.map((map) => Gift.fromMap(map)).toList();
  }

  Future<Gift?> fetchGiftById(int id) async {
    final db = await database;
    print('Fetching gift with ID: $id');
    final results = await db.query(
      'gifts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isNotEmpty) {
      print('Gift found: ${results.first}');
      return Gift.fromMap(results.first);
    }
    print('Gift with ID $id not found');
    return null;
  }

  Future<int> updateGift(Gift gift) async {
    final db = await database;
    print('Updating gift with ID: ${gift.id}');
    final rowsUpdated = await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
    print('Updated $rowsUpdated rows for gift ID: ${gift.id}');
    return rowsUpdated;
  }

  Future<int> deleteGift(int giftId) async {
    final db = await database;
    print('Deleting gift with ID: $giftId');
    final rowsDeleted = await db.delete(
      'gifts',
      where: 'id = ?',
      whereArgs: [giftId],
    );
    print('Deleted $rowsDeleted rows for gift ID: $giftId');
    return rowsDeleted;
  }

  Future<int> deleteGiftsByEventId(int eventId) async {
    final db = await database;
    print('Deleting gifts for event ID: $eventId');
    final rowsDeleted = await db.delete(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );
    print('Deleted $rowsDeleted gifts for event ID: $eventId');
    return rowsDeleted;
  }
}
