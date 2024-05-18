import 'package:flutter/material.dart';
import 'package:edu_buddy/Database/database_helper.dart';

import 'package:edu_buddy/Screens/FirstScreen.dart';
import 'package:edu_buddy/Screens/HomeScreen.dart';
import 'package:edu_buddy/Screens/Create.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the database
  await DatabaseHelper.initDatabase();
  int x = await DatabaseHelper.getFirstTimeLoaded();


  runApp(MyApp(initialScreen: x == 0 ? FirstScreen() : HomeScreen()));

}



class MyApp extends StatelessWidget {
  final Widget initialScreen;

  const MyApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: initialScreen,
      //home: Create(),
    );
  }
}
