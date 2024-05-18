import 'dart:math';

import 'package:edu_buddy/Screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:edu_buddy/Database/database_helper.dart';
import 'package:sqflite/sqflite.dart';


class MemoryTestScreen extends StatefulWidget {
  final List<String> words;

  MemoryTestScreen({Key? key, required this.words}) : super(key: key);

  @override
  State<MemoryTestScreen> createState() => _MemoryTestScreenState();
}

class _MemoryTestScreenState extends State<MemoryTestScreen> {
  late List<String> newWords;
  late List<String> finalWords = [];
  List<bool> selectedWords = [];

  @override
  void initState() {
    super.initState();
    newWords = generateWordPairs()
        .take(25)
        .map((pair) => pair.asPascalCase)
        .toList();
    finalWords = List.from(widget.words)..addAll(newWords);
    finalWords.shuffle(Random());
    selectedWords = List.filled(finalWords.length, false);
  }

  Future<void> saveMemoryEfficiency(int mE) async {
    final Database db = await DatabaseHelper.database;
    await db.rawInsert('''
          UPDATE UserDetails
          SET memoryEfficiency = $mE
          WHERE id = 1;
        ''');
  }

  void _showSelectedWordCount(BuildContext context) {
    int count = 0;
    for (int i = 0; i < finalWords.length; i++) {
      if (selectedWords[i] && !newWords.contains(finalWords[i])) {
        count++;
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selected Words'),
          content: Text('Number of selected words: $count'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                saveMemoryEfficiency(count);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HomeScreen()),
                );

              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(

                "Select the words which you remembered!",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set background color here
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                      itemCount: finalWords.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: CheckboxListTile(
                            title: Text(finalWords[index]),
                            value: selectedWords[index],
                            onChanged: (bool? value) {
                              setState(() {
                                selectedWords[index] = value!;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
                child: Spacer(),
              ),
              ElevatedButton(

                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(15),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  _showSelectedWordCount(context);
                },
                child: const Text(
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16
                    ),
                    "Check my memory"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
