import 'dart:io';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadFile();
  }

  Future<void> _loadFile() async {
    try {
      String contents = await _readFile('/storage/emulated/0/EduBuddy/Short Notes/Created/' + widget.filePath);
      print('File contents: $contents');
      List<String> lines = contents.split('\n');
      for (var line in lines) {
        print('Processing line: $line');
        if (line.isNotEmpty) {
          var parts = line.split(' | ');
          if (parts.length == 2) {
            var questionPart = parts[0].split(': ')[1].trim(); // Extract question part
            var answerPart = parts[1].split(': ')[1].trim(); // Extract answer part
            questionsAndAnswers.add({'question': questionPart, 'answer': answerPart});
          }
        }
      }
      if (questionsAndAnswers.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = 'No questions found in the file.';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading file: $e';
        isLoading = false;
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
            Text(
              currentAnswer.isNotEmpty ? 'Answer: $currentAnswer' : '',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _previousQuestion,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  child: Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
