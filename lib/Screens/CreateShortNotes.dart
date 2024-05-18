import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class Createshortnotes extends StatefulWidget {
  const Createshortnotes({Key? key}) : super(key: key);

  @override
  State<Createshortnotes> createState() => _CreateshortnotesState();
}

class _CreateshortnotesState extends State<Createshortnotes> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  List<String> notes = [];
  int noteCounter = 1; // Counter to keep track of notes

  void _addNote() {
    String question = questionController.text.trim();
    String answer = answerController.text.trim();
    if (question.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        notes.add("$noteCounter. Q:$question | A:$answer"); // Add note with counter
        noteCounter++; // Increment counter
        questionController.clear();
        answerController.clear();
      });
    }
  }

  Future<void> _saveNotes(String fileName) async {
    String notesContent = notes.join("\n");
    try {
      final Directory? directory = await getExternalStorageDirectory();
      final String dirPath = '/storage/emulated/0/EduBuddy/Short Notes/Created';
      await Directory(dirPath).create(recursive: true);
      final File file = File('$dirPath/$fileName.txt');
      await file.writeAsString(notesContent);
      String filePath = file.path;
      Navigator.pop(context); // Dismiss the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: Text("File saved as $fileName at $filePath."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Dismiss the success dialog
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to save notes: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(labelText: 'Question'),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: answerController,
              decoration: InputDecoration(labelText: 'Answer'),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addNote,
                  child: Text('Next'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController fileNameController =
                        TextEditingController();
                        return AlertDialog(
                          title: Text("Save Document"),
                          content: TextField(
                            controller: fileNameController,
                            decoration:
                            InputDecoration(labelText: "Enter Filename"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                String fileName =
                                fileNameController.text.trim();
                                if (fileName.isNotEmpty) {
                                  await _saveNotes(fileName);
                                }
                              },
                              child: Text("OK"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Text('Save'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    title: Text(notes[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Createshortnotes(),
  ));
}
