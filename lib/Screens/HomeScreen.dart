import 'dart:io';
import 'package:edu_buddy/Screens/CreateShortNotes.dart';
import 'package:flutter/material.dart';
import 'package:edu_buddy/Screens/MemoryMeasureScreen.dart';
import 'package:edu_buddy/Database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'ViewShortNotes.dart';
import 'CreateTimeTable.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _nameController = TextEditingController();
  String userName = ''; // Variable to store the user's input

  int currentIndex = 0;
  String title = "";

  @override
  void initState() {
    super.initState();
    // Call the method to load existing username when Settings screen is opened
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final Database db = await DatabaseHelper.database;
    List<Map<String, dynamic>> result = await db.query('UserDetails',
        columns: ['UserName'], where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      setState(() {
        // Set the retrieved username to the text field
        _nameController.text = result[0]['UserName'];
      });
    }
  }

  Future<void> saveName(String userName) async {
    final Database db = await DatabaseHelper.database;
    await db.rawInsert('''
          UPDATE UserDetails
          SET UserName = '$userName'
          WHERE id = 1;
        ''');
  }

  @override
  Widget build(BuildContext context) {
    Widget selectedWidget;
    switch (currentIndex) {
      case 0:
        title = 'Home';
        selectedWidget = Container(
          color: Colors.white,
          child: const Center(
            child: Text("Home Screen", style: TextStyle(fontSize: 20)),
          ),
        );
        break;
      case 1:
        title = 'Notes';
        selectedWidget = Container(
          color: Colors.white,
          child: Column(
            children: [
              Container(
                color: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("All Short Notes", style: TextStyle(color: Colors.white, fontSize: 18)),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Createshortnotes()),
                        );
                      },
                      child: Text("Create"),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _getTextFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<String>? textFiles = snapshot.data;
                      if (textFiles != null && textFiles.isNotEmpty) {
                        return ListView.separated(
                          itemCount: textFiles.length,
                          separatorBuilder: (context, index) => const Divider(
                            color: Colors.grey,
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text(
                                textFiles[index],
                                style: TextStyle(fontSize: 16),
                              ),
                              onTap: () {
                                // Add logic to handle tapping on a file
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortNotes(filePath: textFiles[index]),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      } else {
                        return Center(child: Text('No text files found'));
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        );
        break;
      case 2:
        title = 'Time Table';
        selectedWidget = Container(
          color: Colors.white,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Createtimetable()),
                  );
                }, child: Text('Create Time Table')),
                ElevatedButton(onPressed: (){}, child: Text('View Time Table')),
              ],
            ),
          ),
        );
        break;
      case 3:
        title = 'Settings';
        selectedWidget = Container(
          color: Colors.white,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Settings",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Get the text from the text field
                  String userInput = _nameController.text;
                  // Assign it to the userName variable
                  userName = userInput;
                  // Call saveName method if needed
                  await saveName(userName);
                },
                child: const Text('Save'),
              ),
              Container(
                color: Colors.cyan,
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: TextButton(
                    child: const Text('Change Memory Efficiency'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MemoryMeasureScreen()),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        );
        break;

      default:
        selectedWidget = Container();
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: Text(
            title,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: selectedWidget,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.blue,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.home,
                  color: Colors.blue,
                ),
                label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.notes,
                  color: Colors.blue,
                ),
                label: 'Notes'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.schedule,
                  color: Colors.blue,
                ),
                label: 'Time Table'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                  color: Colors.blue,
                ),
                label: 'Settings')
          ],
          currentIndex: currentIndex,
          onTap: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Future<List<String>> _getTextFiles() async {
    Directory directory = Directory(
        '/storage/emulated/0/EduBuddy/Short Notes/Created');
    List<FileSystemEntity> fileList = directory.listSync();
    List<String> textFiles = [];
    for (FileSystemEntity entity in fileList) {
      if (entity is File && entity.path.endsWith('.txt')) {
        textFiles.add(entity.path.split('/').last); // Get only the file name
      }
    }
    return textFiles;
  }
}
