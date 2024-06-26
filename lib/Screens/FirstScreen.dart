import 'package:edu_buddy/Screens/MemoryMeasureScreen.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:edu_buddy/Database/database_helper.dart';
import 'package:sqflite/sqflite.dart';


class FirstScreen  extends StatefulWidget {
  const FirstScreen ({super.key});

  @override
  State<FirstScreen > createState() => _FirstScreenState ();
}

class _FirstScreenState  extends State<FirstScreen > {

  bool showButton = false;
  bool showImage = false;

  Future<void> _initializeFirstTimeLoaded() async {
    final Database db = await DatabaseHelper.database;
    await db.rawInsert('''
          UPDATE UserDetails
          SET FirstTimeLoaded = 1
          WHERE id = 1;
        ''');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack( // Use Stack for flexible positioning
          children: [
            Center( // Center the animated text
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,

                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: AnimatedTextKit(
                        animatedTexts: [

                          FadeAnimatedText(
                              "Hello there",
                              duration: const Duration(milliseconds: 3000),
                              textAlign: TextAlign.center
                          ),
                          FadeAnimatedText(
                              "Welcome to Edu Buddy app",
                              duration: const Duration(milliseconds: 3000),
                              textAlign: TextAlign.center
                          ),
                          FadeAnimatedText(
                            "This is the modern method to studies.",
                            textAlign: TextAlign.center,
                            duration: const Duration(milliseconds: 3000),
                          ),
                          FadeAnimatedText(
                              "Let's test your brain buddy,",
                              duration: const Duration(milliseconds: 3000),
                              textAlign: TextAlign.center
                          ),
                        ],
                        onFinished: () async {
                          // Insert the initialization part here
                          await _initializeFirstTimeLoaded();
                          setState(() {
                            showButton = true; // Show button after a delay
                            showImage = true;
                          });
                        },
                        totalRepeatCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: showImage,
              child: Center(
                child: Positioned(
                    child: Image.asset(
                      'assets/images/vectors/brainTest.png',
                      height: 300,
                    )
                ),
              ),
            ),
            Visibility(
              visible: showButton,
              child: Positioned( // Position the button at the bottom
                bottom: 20.0, // Adjust margin as needed
                left: 20.0, // Align to the left (optional)
                right: 20.0, // Align to the right (optional)
                child: ElevatedButton(

                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(15),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // Navigate to HomeScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MemoryMeasureScreen()),
                    );
                  },
                  child: const Text(
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                      "Get started"
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
