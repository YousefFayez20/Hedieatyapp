import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event.dart';
import '../models/gift.dart';
import '../models/friend.dart';
import '../models/user.dart';

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
    final String path = join(await getDatabasesPath(), 'hedieaty.db');
    print("Database path: $path");
    return openDatabase(
      path,
      version: 11, // Incremented version for schema updates
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: onDatabaseDowngradeDelete,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    print("Running onCreate...");
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        preferences TEXT
      )
    ''');
    print("Users table created.");

    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        profile_image TEXT,
        upcoming_events INTEGER DEFAULT 0,
        user_id INTEGER,
        firebase_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    print("Friends table created.");

    await db.execute('''
      CREATE TABLE events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        location TEXT,
        description TEXT,
        user_id INTEGER NOT NULL,
        friend_id INTEGER NULL, -- Nullable for personal events
        category TEXT,
        status TEXT,
        firebase_id TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id),
        FOREIGN KEY (friend_id) REFERENCES friends (id)
      )
    ''');
    print("Events table created.");

    await db.execute('''
    CREATE TABLE gifts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      description TEXT,
      category TEXT,
      price REAL,
      status TEXT,
      event_id INTEGER NOT NULL,
      image_url TEXT, -- Add this column
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      FOREIGN KEY (event_id) REFERENCES events (id)
    )
  ''');
    print("Gifts table created.");
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print("Upgrading database from version $oldVersion to $newVersion...");

    if (oldVersion < newVersion) {
      // Drop all tables and recreate them
      await db.execute('DROP TABLE IF EXISTS users');
      await db.execute('DROP TABLE IF EXISTS friends');
      await db.execute('DROP TABLE IF EXISTS events');
      await db.execute('DROP TABLE IF EXISTS gifts');
      await _onCreate(db, newVersion);
    }
  }


  Future<void> resetDatabase() async {
    final String path = join(await getDatabasesPath(), 'hedieaty.db');
    await deleteDatabase(path);
    print("Database reset successfully.");
  }
  /// New method to delete and recreate the database
  Future<void> recreateDatabase() async {
    final String path = join(await getDatabasesPath(), 'hedieaty.db');

    if (await databaseExists(path)) {
      print('Deleting database at $path...');
      await deleteDatabase(path);
      print('Database deleted. It will be recreated on the next run.');
      _database = null; // Ensure the database is reset in the current app session
    } else {
      print('Database does not exist. No need to delete.');
    }
  }
  // ------------------- User-Related Functions -------------------
  Future<int> insertUser(User user) async {
    final db = await database;
    print("Inserting user: ${user.toMap()}");
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    print("Fetching user by email: $email");
    final results = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (results.isNotEmpty) {
      print("User found: ${results.first}");
      return User.fromMap(results.first);
    }
    print("No user found with email: $email");
    return null;
  }
// Inside DatabaseHelper class
  Future<String?> getEmailByUserId(int userId) async {
    final db = await database;
    final results = await db.query('users', where: 'id = ?', whereArgs: [userId]);

    if (results.isNotEmpty) {
      return results.first['email'] as String?;
    }
    return null;
  }

  Future<bool> validateUser(String email, String password) async {
    final db = await database;
    print("Validating user with email: $email");
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    final isValid = results.isNotEmpty;
    print("User validation result: $isValid");
    return isValid;
  }

  Future<int?> validateUserAndGetId(String email, String password) async {
    final db = await database;
    print("Validating and fetching user ID for email: $email");
    final results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    if (results.isNotEmpty) {
      final userId = results.first['id'] as int?;
      print("User ID found: $userId");
      return userId;
    }
    print("No user found with provided credentials.");
    return null;
  }

  Future<User?> getUserById(int userId) async {
    final db = await database;
    print("Fetching user by ID: $userId");
    final results = await db.query('users', where: 'id = ?', whereArgs: [userId]);
    if (results.isNotEmpty) {
      print("User found: ${results.first}");
      return User.fromMap(results.first);
    }
    print("No user found with ID: $userId");
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    print("Updating user with ID: ${user.id}");
    return await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  // ------------------- Friend-Related Functions -------------------
  Future<int> insertFriend(Friend friend) async {
    final db = await database;
    print("Inserting friend: ${friend.toMap()}");
    return await db.insert(
        'friends',
        friend.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace
    );
  }
  Future<Friend?> fetchFriendById(int friendId) async {
    final db = await database;
    final results = await db.query('friends', where: 'id = ?', whereArgs: [friendId]);
    if (results.isNotEmpty) {
      return Friend.fromMap(results.first);
    }
    return null;
  }
  Future<void> printDatabaseContents() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('friends');
    print('Database contents: $result');
  }

  Future<List<Friend>> fetchAllFriends(int userId) async {
    final db = await database;
    print("Fetching all friends for user ID: $userId");
    final results = await db.query('friends', where: 'user_id = ?', whereArgs: [userId]);
    return results.map((map) => Friend.fromMap(map)).toList();
  }

  Future<int> deleteFriend(int friendId) async {
    final db = await database;
    print("Deleting friend with ID: $friendId");
    return await db.delete('friends', where: 'id = ?', whereArgs: [friendId]);
  }

  Future<int> updateFriend(Friend friend) async {
    final db = await database;
    print("Updating friend with ID: ${friend.id}");
    return await db.update(
      'friends',
      friend.toMap(),
      where: 'id = ?',
      whereArgs: [friend.id],
    );
  }

  // ------------------- Event-Related Functions -------------------
  Future<void> insertEvent(Event event) async {
    final db = await database;
    // Ensure event is inserted with the correct userId and friendId
    assert(event.userId != null, "User ID must not be null for an event.");
    await db.insert('events', event.toMap());
    print("Event inserted: ${event.toMap()}");
  }




  Future<List<Event>> fetchAllEvents() async {
    final db = await database;
    print("Fetching all events.");
    final results = await db.query('events');
    return results.map((map) => Event.fromMap(map)).toList();
  }

  Future<List<Event>> fetchEventsByUserId(int userId) async {
    final db = await database;
    final results = await db.query(
      'events',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    print('Fetched events for user $userId: $results');
    return results.map((map) => Event.fromMap(map)).toList();
  }

  Future<List<Event>> fetchEventsForUser(int userId, {int? friendId}) async {
    final db = await database;

    // Fetch events either personal or specific to a friend
    final whereClause = friendId == null
        ? 'user_id = ? AND friend_id IS NULL' // Personal events
        : 'friend_id = ?'; // Friend-specific events

    final whereArgs = friendId == null ? [userId] : [friendId];

    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) => Event.fromMap(maps[i]));
  }


  Future<int> deleteEvent(int id) async {
    final db = await database;
    print("Deleting event with ID: $id");
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateEvent(Event event) async {
    final db = await database;
    print("Updating event with ID: ${event.id}");
    return await db.update(
      'events',
      event.toMap(),
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  // ------------------- Gift-Related Functions -------------------
  Future<void> insertGift(Gift gift) async {
    final db = await database;
    await db.insert('gifts', gift.toMap());
    print("Gift inserted: ${gift.name}");
  }


  Future<List<Gift>> fetchGiftsByEventId(int eventId) async {
    final db = await database;
    print("Fetching gifts for event ID: $eventId");
    final results = await db.query('gifts', where: 'event_id = ?', whereArgs: [eventId]);
    return results.map((map) => Gift.fromMap(map)).toList();
  }
  Future<List<Gift>> fetchGiftsForEvent(int eventId) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      'gifts',
      where: 'event_id = ?',
      whereArgs: [eventId],
    );

    return List.generate(maps.length, (i) => Gift.fromMap(maps[i]));
  }


  Future<int> deleteGift(int id) async {
    final db = await database;
    print("Deleting gift with ID: $id");
    return await db.delete('gifts', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateGift(Gift gift) async {
    final db = await database;
    print("Updating gift with ID: ${gift.id}");
    return await db.update(
      'gifts',
      gift.toMap(),
      where: 'id = ?',
      whereArgs: [gift.id],
    );
  }

  Future<List<Map<String, dynamic>>> fetchGiftsByFriendGroupedByEvent(int friendId) async {
    final db = await database;

    print("Fetching gifts grouped by events for friend ID: $friendId");

    // Ensure the query filters by the friend_id correctly
    final results = await db.rawQuery('''
    SELECT 
      events.id AS event_id, 
      events.name AS event_name, 
      events.date AS event_date, 
      events.status AS event_status, 
      gifts.id AS gift_id, 
      gifts.name AS gift_name, 
      gifts.category AS gift_category, 
      gifts.price AS gift_price, 
      gifts.status AS gift_status
    FROM events
    LEFT JOIN gifts ON events.id = gifts.event_id
    WHERE events.friend_id = ? -- Filter by friend_id
    ORDER BY events.date ASC
  ''', [friendId]);

    print("Raw query results: $results");

    // Group results by event
    Map<int, Map<String, dynamic>> groupedEvents = {};
    for (var row in results) {
      final eventId = row['event_id'] as int;
      if (!groupedEvents.containsKey(eventId)) {
        groupedEvents[eventId] = {
          'event_id': eventId,
          'event_name': row['event_name'],
          'event_date': row['event_date'],
          'event_status': row['event_status'],
          'gifts': []
        };
      }

      // Add gift details if available
      if (row['gift_id'] != null) {
        groupedEvents[eventId]!['gifts'].add({
          'gift_id': row['gift_id'],
          'gift_name': row['gift_name'],
          'gift_category': row['gift_category'],
          'gift_price': row['gift_price'],
          'gift_status': row['gift_status'],
        });
      }
    }

    final groupedResults = groupedEvents.values.toList();
    print("Grouped results: $groupedResults");
    return groupedResults;
  }

  Future<List<Event>> fetchPersonalEvents(int userId) async {
    final db = await database;

    // Query personal events where friend_id is NULL (no friend associated)
    final results = await db.query(
      'events',
      where: 'user_id = ? AND friend_id IS NULL',
      whereArgs: [userId],
    );

    return results.map((map) => Event.fromMap(map)).toList();
  }


  Future<List<Map<String, dynamic>>> fetchPledgedGifts(int userId) async {
    final db = await database;
    final results = await db.rawQuery(''' 
    SELECT 
      g.id AS gift_id, g.name AS gift_name, g.description, g.category AS gift_category,
      g.price AS gift_price, g.status AS gift_status, g.event_id AS gift_event_id,
      g.image_url, g.created_at AS gift_created_at, g.updated_at AS gift_updated_at,
      e.date AS event_date, f.name AS friend_name
    FROM gifts g
    LEFT JOIN events e ON g.event_id = e.id
    LEFT JOIN friends f ON e.friend_id = f.id
    WHERE g.status = 'Pledged' AND e.user_id = ?
    ORDER BY e.date
  ''', [userId]);
    return results;
  }

// Inside your DatabaseHelper class
  Future<int> updateGiftStatus(int giftId, String status) async {
    final db = await database;

    // Update the status of the gift
    final result = await db.update(
      'gifts',
      {'status': status, 'updated_at': DateTime.now().toString()},
      where: 'id = ?',
      whereArgs: [giftId],
    );

    print("Gift status updated: $status for gift ID: $giftId");
    return result;
  }
  Future<List<Event>> fetchEventsByFriendId(int friendId) async {
    final db = await database;

    final results = await db.query(
      'events',
      where: 'friend_id = ?',
      whereArgs: [friendId],
    );

    return results.map((map) => Event.fromMap(map)).toList();
  }
  Future<int> fetchUpcomingEventCountByFriendId(int friendId) async {
    final db = await database;

    // Get today's date to filter events that are upcoming
    final today = DateTime.now();
    final formattedToday = DateFormat("yyyy-MM-dd").format(today);

    final results = await db.query(
      'events',
      where: 'friend_id = ? AND date > ?',
      whereArgs: [friendId, formattedToday],  // Only fetch upcoming events
    );

    return results.length; // Return the count of upcoming events
  }
  Future<int> fetchTotalEventCountByFriendId(int friendId) async {
    final db = await database;

    final result = await db.query(
      'events',
      where: 'friend_id = ?',
      whereArgs: [friendId],
    );

    return result.length; // Return the total count of events for this friend
  }

  Future<Friend?> getFriendByFirebaseId(String firebaseId) async {
    final db = await database;
    print("Fetching friend by Firebase ID: $firebaseId");

    final results = await db.query(
        'friends',
        where: 'firebase_id = ?',
        whereArgs: [firebaseId]
    );

    if (results.isNotEmpty) {
      print("Friend found: ${results.first}");
      return Friend.fromMap(results.first);
    }

    print("No friend found with Firebase ID: $firebaseId");
    return null;
  }
  Future<int> insertOrUpdateFriend(Friend friend) async {
    final db = await database;

    // Check if the friend already exists in the database by their firebase_id
    final existingFriend = await _getFriendByFirebaseId(friend.firebaseId!);

    if (existingFriend != null) {
      // If the friend exists, update them (if needed) or just return their existing ID
      print("Friend already exists: ${existingFriend.name}");
      return existingFriend.id!;
    }

    // If the friend doesn't exist, insert them into the database
    print("Inserting new friend: ${friend.toMap()}");
    return await db.insert('friends', friend.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

// Helper method to fetch friend by firebase_id
  Future<Friend?> _getFriendByFirebaseId(String firebaseId) async {
    final db = await database;

    // Query the database to check if a friend with the same firebase_id already exists
    final results = await db.query(
      'friends',
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );

    // Return the first result if found, otherwise return null
    if (results.isNotEmpty) {
      return Friend.fromMap(results.first);
    }
    return null;
  }

// Method to fetch friends from Firestore and insert/update them in the local database
  Future<void> syncFriendsFromFirestore(List<Friend> friendsFromFirestore) async {
    for (var friend in friendsFromFirestore) {
      // Insert or update the friend in the local database
      await insertOrUpdateFriend(friend);
    }
  }
  Future<Friend?> fetchFriendByFirebaseId(String firebaseId) async {
    final db = await database;

    final result = await db.query(
      'friends',
      where: 'firebase_id = ?',
      whereArgs: [firebaseId],
    );

    if (result.isNotEmpty) {
      return Friend.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<Event?> fetchEventById(int eventId) async {
    final db = await database;
    print("Fetching event by ID: $eventId");
    final results = await db.query(
      'events',
      where: 'id = ?',
      whereArgs: [eventId],
    );
    if (results.isNotEmpty) {
      print("Event found: ${results.first}");
      return Event.fromMap(results.first);
    }
    print("No event found with ID: $eventId");
    return null;
  }
  Future<String?> getFirebaseIdByFriendId(int friendId) async {
    final db = await database;
    final results = await db.query(
      'friends',
      where: 'id = ?',
      whereArgs: [friendId],
    );

    if (results.isNotEmpty) {
      return results.first['firebase_id'] as String?;
    }
    return null;
  }

}