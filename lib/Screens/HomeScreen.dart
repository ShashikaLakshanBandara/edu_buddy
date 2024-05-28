import 'dart:io';
import 'package:edu_buddy/Screens/CreateShortNotes.dart';
import 'package:flutter/material.dart';
import 'package:edu_buddy/Screens/MemoryMeasureScreen.dart';
import 'package:edu_buddy/Database/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'EditShortNotes.dart';
import 'ViewShortNotes.dart';
import 'CreateTimeTable.dart';
import 'ViewTimeTable.dart';

import 'package:file_picker/file_picker.dart';


import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _nameController = TextEditingController();
  String userName = ''; // Variable to store the user's input

  int currentIndex = 0;
  String title = "";
  double totalSpendTime = 0.0;

  bool _hasPermission = false;

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

  @override
  void initState() {
    super.initState();
    // Call the method to load existing username when Settings screen is opened
    _loadDetails();
    _requestPermission();
  }
  Future<void> copyFile(String sourcePath, String destinationPath) async {
    try {
      final sourceFile = File(sourcePath);
      final destinationFile = File(destinationPath);

      if (await destinationFile.exists()) {
        // Handle existing file (e.g., prompt user for overwrite)
        print('Destination file already exists. Overwrite?');
      }

      await sourceFile.copy(destinationPath);
      print('File copied successfully!');
    } on FileSystemException catch (e) {
      print('Error copying file: $e');
      // Handle errors (e.g., insufficient permissions)
    }
  }


  Future<void> _requestPermission() async {
    _hasPermission = await _requestPer(Permission.storage);
    setState(() {});
  }

  Future<void> _loadDetails() async {
    final Database db = await DatabaseHelper.database;
    List<Map<String, dynamic>> result = await db.query('UserDetails',
        columns: ['UserName', 'usage'], where: 'id = ?', whereArgs: [1]);

    if (result.isNotEmpty) {
      setState(() {
        // Set the retrieved username to the text field
        _nameController.text = result[0]['UserName'];
        userName = result[0]['UserName'];
        double usageInSeconds = result[0]['usage'] / (60 * 60);
        totalSpendTime = double.parse(usageInSeconds.toStringAsFixed(3));
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
    if (currentIndex == 0) {
      _loadDetails(); // Load the username when the home screen is built
    }
    Widget selectedWidget;
    switch (currentIndex) {
      case 0:
        title = 'Home';
        selectedWidget = Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage:
                          AssetImage('assets/images/vectors/profilePic.jpg'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardItem(title: 'Total Short Notes', value: '24'),
                    DashboardItem(
                        title: 'Total Spend Time(hours)',
                        value: '$totalSpendTime'),
                    DashboardItem(title: 'Total Hard Question', value: '50'),
                    DashboardItem(title: 'Total Normal Question', value: '50'),
                    DashboardItem(title: 'Total Easy Question', value: '50'),
                  ],
                ),
              ],
            ),
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
                color: Colors.blue,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await FilePicker.platform.pickFiles(
                          allowMultiple: false, // Only allow single file selection
                          type: FileType.custom, // Filter for text files only
                          allowedExtensions: ['txt'],
                        );

                        if (result != null) {
                          final platformFile = result.files.single;
                          final filePath = platformFile.path!; // Get the selected file path

                          // Call the copy function to copy the file
                          await copyFile(filePath, '/storage/emulated/0/EduBuddy/Short Notes/Created/${platformFile.name}');
                        } else {
                          // Handle case where user cancels or no file is selected
                          print('No file selected.');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black26),
                      child: const Text(
                        "Import Short Note",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Createshortnotes(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black26),
                      child: const Text(
                        "Create Short Note",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _getTextFiles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
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
                                style: const TextStyle(fontSize: 16),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewShortNotes(
                                        filePath: textFiles[index]),
                                  ),
                                );
                              },
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditShortNotes(
                                              filePath: textFiles[index]),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      // Add logic to handle deleting a file
                                      // Add logic to handle deleting a file
                                      String filePath =
                                          '/storage/emulated/0/EduBuddy/Short Notes/Created/${textFiles[index]}';
                                      File file = File(filePath);

                                      // Check if the file exists before attempting to delete it
                                      if (await file.exists()) {
                                        await file.delete();
                                        setState(() {
                                          // Refresh the list by removing the deleted file
                                          textFiles.removeAt(index);
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        return const Center(child: Text('No text files found'));
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CreateTimetable()),
                      );
                    },
                    child: const Text('Create Time Table')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewTimeTable()),
                      );
                    },
                    child: const Text('View Time Table')),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Get the text from the text field
                  String userInput = _nameController.text;
                  // Assign it to the userName variable
                  setState(() {
                    userName = userInput;
                  });
                  // Call saveName method if needed
                  await saveName(userName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Save',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                color: Colors.cyan,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MemoryMeasureScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Change Memory Efficiency',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
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
    Directory directory =
        Directory('/storage/emulated/0/EduBuddy/Short Notes/Created');
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

class DashboardItem extends StatelessWidget {
  final String title;
  final String value;

  const DashboardItem({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
