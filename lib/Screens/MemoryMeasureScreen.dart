import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'dart:async';
import 'MemoryTestScreen.dart';

void main() {
  runApp(const MemoryMeasureScreen());
}

class MemoryMeasureScreen extends StatefulWidget {
  const MemoryMeasureScreen({super.key});

  @override
  State<MemoryMeasureScreen> createState() => _MemoryMeasureScreenState();
}

class _MemoryMeasureScreenState extends State<MemoryMeasureScreen> {
  List<String> words = [
    "Loading...",
    "Loading...",
    "Loading...",
    "Loading...",
    "Loading...",
    "Loading..."
  ];
  bool showButton = true;
  int countdown = 5;
  Timer? _timer;

  void startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      } else {
        _timer?.cancel();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MemoryTestScreen(words: words),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    "Try to Remember below words as you can"),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue, // Set background color here
                    borderRadius: BorderRadius.circular(15),
                  ), // Set border radius here

                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      height: 500,
                      width: double.maxFinite,
                      child: Center(
                        child: ListView(
                          children: words
                              .map((word) => Card(
                            child: ListTile(
                              title: Text(word),
                            ),
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                  child: Spacer(),
                ),
                Visibility(
                  visible: !showButton,
                  child: Text(
                    'Time remaining: $countdown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Visibility(
                  visible: showButton,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(15),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        MediaQuery.of(context).size.width *
                            0.9, // Set button width to 90% of screen width
                        MediaQuery.of(context).size.width *
                            0.1, // Set button height to 0.1% of screen width
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        words = generateWordPairs()
                            .take(25)
                            .map((pair) => pair.asPascalCase)
                            .toList();
                        showButton = false;
                        startCountdown();
                      });
                    },
                    child: const Text(
                      "Start",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
