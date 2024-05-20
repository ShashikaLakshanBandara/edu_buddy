import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class EditShortNotes extends StatefulWidget {
  final String filePath;

  const EditShortNotes({Key? key, required this.filePath}) : super(key: key);

  @override
  State<EditShortNotes> createState() => _EditShortNotesState();
}

class _EditShortNotesState extends State<EditShortNotes> {
  List<Map<String, String>> questionsAndAnswers = [];
  int currentQuestionIndex = 0;
  bool isLoading = true;
  String errorMessage = '';
  late Database _database;
  String tableName = '';
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();

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
      await _createTable();

      // Load file and populate the form fields
      await _loadQuestionsFromDatabase();

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

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'edubuddyDatabase.db');
    return openDatabase(path, version: 1);
  }

  String _sanitizeTableName(String name) {
    // Sanitize the table name to avoid SQL injection and invalid characters
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

  Future<void> _loadQuestionsFromDatabase() async {
    try {
      final List<Map<String, dynamic>> maps = await _database.query(tableName);
      questionsAndAnswers = List.generate(maps.length, (i) {
        return {
          'question': maps[i]['Question'],
          'answer': maps[i]['Answer'],
        };
      });
      if (questionsAndAnswers.isNotEmpty) {
        _populateFields(currentQuestionIndex);
      } else {
        setState(() {
          errorMessage = 'No questions found in the file.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading questions from database: $e';
      });
    }
  }

  void _populateFields(int index) {
    questionController.text = questionsAndAnswers[index]['question']!;
    answerController.text = questionsAndAnswers[index]['answer']!;
  }

  void _nextQuestion() {
    if (currentQuestionIndex < questionsAndAnswers.length - 1) {
      setState(() {
        currentQuestionIndex++;
        _populateFields(currentQuestionIndex);
      });
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        _populateFields(currentQuestionIndex);
      });
    }
  }

  Future<void> _saveChanges() async {
    try {
      String updatedQuestion = questionController.text;
      String updatedAnswer = answerController.text;

      questionsAndAnswers[currentQuestionIndex] = {
        'question': updatedQuestion,
        'answer': updatedAnswer
      };

      await _database.update(
        tableName,
        {
          'Question': updatedQuestion,
          'Answer': updatedAnswer
        },
        where: 'QuestionNumber = ?',
        whereArgs: [currentQuestionIndex + 1],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await _updateTextFile();

      setState(() {
        // Changes saved, no additional UI update needed
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error saving changes: $e';
      });
    }
  }

  Future<void> _updateTextFile() async {
    try {
      String newPath = '/storage/emulated/0/EduBuddy/Short Notes/Created/' + widget.filePath;
      StringBuffer buffer = StringBuffer();
      for (var qa in questionsAndAnswers) {
        buffer.writeln('Question: ${qa['question']} | Answer: ${qa['answer']}');
      }
      File file = File(newPath);
      await file.writeAsString(buffer.toString().trim());
    } catch (e) {
      setState(() {
        errorMessage = 'Error updating text file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.filePath.split('/').last.split('.').first}'),
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
            TextField(
              controller: questionController,
              decoration: InputDecoration(
                labelText: 'Question',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Answer',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
            ),
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
