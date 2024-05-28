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
            memoryEfficiency DOUBLE,
            usage DOUBLE,
            FirstTimeLoaded INTEGER
          )
        ''');
        await db.rawInsert('''
          INSERT INTO UserDetails (UserName, memoryEfficiency, usage, FirstTimeLoaded)
          VALUES ('No name inserted', 0, 0, 0)
        ''');

        // Create timetable table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Timetable (
            id INTEGER PRIMARY KEY,
            day TEXT,
            startingTime TEXT,
            endingTime TEXT,
            task TEXT
          )
        ''');

        // Create timetable table
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Timetable (
            id INTEGER PRIMARY KEY,
            day TEXT,
            startingTime TEXT,
            endingTime TEXT,
            task TEXT
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

  // Insert timetable data
  static Future<int> insertTimetable(Map<String, dynamic> timetableData) async {
    final db = await database;
    return await db.insert('Timetable', timetableData);
  }

  // Get all timetable data
  static Future<List<Map<String, dynamic>>> getAllTimetable() async {
    final db = await database;
    return await db.query('Timetable');
  }

  // Get timetable data for a specific day
  static Future<List<Map<String, dynamic>>> getTimetableForDay(String day) async {
    final db = await database;
    return await db.query('Timetable', where: 'day = ?', whereArgs: [day]);
  }

  // Delete all timetable data
  static Future<int> deleteAllTimetable() async {
    final db = await database;
    return await db.delete('Timetable');
  }

  static Future<void> updateTimetable(Map<String, dynamic> updatedTimetableEntry) async {
    final db = await database;
    await db.update(
      'Timetable',
      updatedTimetableEntry,
      where: 'id = ?',
      whereArgs: [updatedTimetableEntry['id']],
    );
  }

}
