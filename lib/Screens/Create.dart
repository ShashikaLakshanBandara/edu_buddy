import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Create extends StatefulWidget {
  const Create({Key? key}) : super(key: key);

  @override
  State<Create> createState() => _CreateState();
}

Future<bool> _request_per(Permission permission) async {
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

class _CreateState extends State<Create> {
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              bool permissionGranted = await _request_per(Permission.storage);
              if (permissionGranted) {
                // Get the external storage directory
                Directory? directory = await getExternalStorageDirectory();
                String? storagePath = directory?.path;
                // Create a new directory
                Directory newDirectory = Directory('/storage/emulated/0/EduBuddy/Short Notes/Created');
                newDirectory.create(recursive: true)
                    .then((Directory directory) {
                  print('New directory created: ${directory.path}');
                  _showLocationPopup(context, directory.path); // Show popup with location
                });
              } else {
                print("Permission is not granted");
              }
            },
            child: Text("Create"),
          ),
        ),
      ),
    );
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
}
