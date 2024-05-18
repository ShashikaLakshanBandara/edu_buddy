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
    final List<Map<String, dynamic>>? result = await _database?.query('UserDetails', columns: ['FirstTimeLoaded']);
    if (result != null && result.isNotEmpty) {
      return result[0]['FirstTimeLoaded'] as int;
    }
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
        await db.execute('''
          CREATE TABLE Timetable (
            id INTEGER PRIMARY KEY,
            dayOfWeek TEXT,
            taskName TEXT,
            startTime TEXT,
            duration INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  static Future<void> createNotesTable(String tableName) async {
    final db = await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        QuestionNumber INTEGER PRIMARY KEY,
        Question TEXT,
        Answer TEXT,
        state TEXT
      )
    ''');
  }
}
