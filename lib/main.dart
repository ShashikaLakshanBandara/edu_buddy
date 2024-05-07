import 'package:flutter/material.dart';
import 'Screens/FirstScreen.dart';
import 'Screens/MemoryMeasureScreen.dart';
import 'Screens/HomeScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: FirstScreen(),
    );
  }
}
