import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  static Future<int> getFirstTimeLoaded() async {
    await initDatabase(); // Ensure database is initialized
    // Use null-aware operator to safely call query method
    final List<Map<String, dynamic>>? result = await _database?.query('UserDetails', columns: ['FirstTimeLoaded']);
    if (result != null && result.isNotEmpty) {
      return result[0]['FirstTimeLoaded'] as int;
    }
    // Return a default value if result is null or no record is found
    return 0;
  }

  static Future initDatabase() async {
    String path = join(await getDatabasesPath(), 'edubuddyDatabase.db');
    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE UserDetails (
            id INTEGER PRIMARY KEY,
            UserName TEXT,
            memoryEfficiency INTEGER,
            usage INTEGER,
            FirstTimeLoaded INTEGER
          )
        ''');
        await db.rawInsert('''
          INSERT INTO UserDetails (UserName, memoryEfficiency, usage, FirstTimeLoaded)
          VALUES ('***', 0, 0, 0)
        ''');
      },
      version: 1,
    );
  }
}
