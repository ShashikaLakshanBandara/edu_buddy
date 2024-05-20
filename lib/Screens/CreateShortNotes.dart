import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Createshortnotes extends StatefulWidget {
  const Createshortnotes({Key? key}) : super(key: key);

  @override
  State<Createshortnotes> createState() => _CreateshortnotesState();
}

Future<bool> _requestPer(Permission permission) async {
  AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
  if (build.version.sdkInt >= 30) {
    var re = await Permission.manageExternalStorage.request();
    if (re.isGranted) {
      return true;
    } else {
      return false;
    }
  } else {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      if (result.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }
}

class _CreateshortnotesState extends State<Createshortnotes> {
  TextEditingController questionController = TextEditingController();
  TextEditingController answerController = TextEditingController();
  List<String> notes = [];
  int noteCounter = 1; // Counter to keep track of notes

  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    _hasPermission = await _requestPer(Permission.storage);
    setState(() {});
  }

  void _addNote() {
    String question = questionController.text.trim();
    String answer = answerController.text.trim();
    if (question.isNotEmpty && answer.isNotEmpty) {
      setState(() {
        notes.add("$noteCounter. Q: $question | A: $answer"); // Add note with counter
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

  void _showLocationPopup(BuildContext context, String location) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("New Folder Location"),
          content: Text(location),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createAndShowDirectory() async {
    if (_hasPermission) {
      // Get the external storage directory
      Directory? directory = await getExternalStorageDirectory();
      String? storagePath = directory?.path;
      // Create a new directory
      Directory newDirectory = Directory('/storage/emulated/0/EduBuddy/Short Notes/Created');
      newDirectory.create(recursive: true).then((Directory directory) {
        print('New directory created: ${directory.path}');
        _showLocationPopup(context, directory.path); // Show popup with location
      });
    } else {
      print("Permission is not granted");
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
              decoration: const InputDecoration(labelText: 'Answer'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addNote,
                  child: const Text('Next'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _createAndShowDirectory();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        TextEditingController fileNameController = TextEditingController();
                        return AlertDialog(
                          title: const Text("Save Document"),
                          content: TextField(
                            controller: fileNameController,
                            decoration: const InputDecoration(labelText: "Enter Filename"),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                String fileName = fileNameController.text.trim();
                                if (fileName.isNotEmpty) {
                                  await _saveNotes(fileName);
                                }
                              },
                              child: const Text("OK"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
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
  runApp(const MaterialApp(
    home: Createshortnotes(),
  ));
}
