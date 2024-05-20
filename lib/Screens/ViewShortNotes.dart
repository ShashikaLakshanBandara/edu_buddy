import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ViewShortNotes extends StatefulWidget {
  final String filePath;

  const ViewShortNotes({Key? key, required this.filePath}) : super(key: key);

  @override
  State<ViewShortNotes> createState() => _ViewShortNotesState();
}

class _ViewShortNotesState extends State<ViewShortNotes> {
  List<Map<String, String>> questionsAndAnswers = [];
  int currentQuestionIndex = 0;
  String currentAnswer = '';
  bool isLoading = true;
  String errorMessage = '';
  late Database _database;
  String tableName = '';

  @override
  void initState() {
    super.initState();
    _initializeDatabaseAndLoadFile();
  }

  Future<void> _initializeDatabaseAndLoadFile() async {
    try {
      // Initialize the database
      _database = await _initDatabase();

      // Create the table based on the file name
      tableName = _sanitizeTableName(widget.filePath.split('/').last.split('.').first);
      bool tableExists = await _checkTableExists(tableName);
      if (!tableExists) {
        await _createTable();
      }

      // Check if the table already has data
      final tableData = await _database.query(tableName);
      if (tableData.isEmpty) {
        // Load file and insert contents into the database if table is empty
        await _loadFile();
      } else {
        // Load data from the database into questionsAndAnswers
        _loadDataFromDatabase(tableData);
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error initializing database or loading file: $e';
        isLoading = false;
      });
    }
  }

  Future<bool> _checkTableExists(String tableName) async {
    final result = await _database.rawQuery('''
    SELECT name FROM sqlite_master WHERE type='table' AND name=?
  ''', [tableName]);

    return result.isNotEmpty;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'edubuddyDatabase.db');
    return openDatabase(path, version: 1);
  }

  String _sanitizeTableName(String name) {
    return name.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
  }

  Future<void> _createTable() async {
    await _database.execute('''
      CREATE TABLE IF NOT EXISTS $tableName (
        QuestionNumber INTEGER PRIMARY KEY,
        Question TEXT,
        Answer TEXT,
        State TEXT
      )
    ''');
  }

  Future<void> _loadFile() async {
    try {
      String contents = await _readFile('/storage/emulated/0/EduBuddy/Short Notes/Created/' + widget.filePath);
      List<String> lines = contents.split('\n');
      int questionNumber = 1;
      for (var line in lines) {
        if (line.isNotEmpty) {
          var parts = line.split(' | ');
          if (parts.length == 2) {
            var questionPart = parts[0].split(': ')[1].trim();
            var answerPart = parts[1].split(': ')[1].trim();
            questionsAndAnswers.add({'question': questionPart, 'answer': answerPart});
            await _database.insert(
              tableName,
              {
                'QuestionNumber': questionNumber,
                'Question': questionPart,
                'Answer': answerPart,
                'State': ''
              },
              conflictAlgorithm: ConflictAlgorithm.ignore, // Use ignore to not replace existing rows
            );
            questionNumber++;
          }
        }
      }
      if (questionsAndAnswers.isEmpty) {
        setState(() {
          errorMessage = 'No questions found in the file.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading file: $e';
      });
    }
  }

  Future<String> _readFile(String filePath) async {
    try {
      File file = File(filePath);
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'Error reading file: $e';
    }
  }

  void _loadDataFromDatabase(List<Map<String, dynamic>> tableData) {
    questionsAndAnswers = tableData.map((row) {
      return {
        'question': row['Question'] as String,
        'answer': row['Answer'] as String,
      };
    }).toList();
  }

  void _showAnswer() {
    setState(() {
      currentAnswer = questionsAndAnswers[currentQuestionIndex]['answer']!;
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questionsAndAnswers.length - 1) {
      setState(() {
        currentQuestionIndex++;
        currentAnswer = ''; // Clear the answer when moving to the next question
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        currentAnswer = ''; // Clear the answer when moving to the previous question
      });
    }
  }

  Future<void> _handleReaction(String reaction) async {
    try {
      await _database.update(
        tableName,
        {'State': reaction},
        where: 'QuestionNumber = ?',
        whereArgs: [currentQuestionIndex + 1],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error updating reaction: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.filePath.split('/').last.split('.').first),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
          ? Center(child: Text(errorMessage))
          : Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${currentQuestionIndex + 1} / ${questionsAndAnswers.length}:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              questionsAndAnswers[currentQuestionIndex]['question']!,
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAnswer,
              child: Text('Show Answer'),
            ),
            SizedBox(height: 20),
            if (currentAnswer.isNotEmpty) ...[
              Text(
                'Answer: $currentAnswer',
                style: TextStyle(fontSize: 16, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _handleReaction('Good'),
                    child: const Text('🙂', style: TextStyle(fontSize: 24)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleReaction('Normal'),
                    child: const Text('😐', style: TextStyle(fontSize: 24)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleReaction('Bad'),
                    child: const Text('☹', style: TextStyle(fontSize: 24)),
                  ),
                ],
              ),
            ],
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: const Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
