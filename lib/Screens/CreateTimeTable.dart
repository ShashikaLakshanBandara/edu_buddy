import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:edu_buddy/Database/database_helper.dart';

class CreateTimetable extends StatefulWidget {
  const CreateTimetable({Key? key}) : super(key: key);

  @override
  State<CreateTimetable> createState() => _CreateTimetableState();
}

class _CreateTimetableState extends State<CreateTimetable> {
  final TextEditingController _subjectController = TextEditingController();
  TimeOfDay? _startingTime;
  TimeOfDay? _endingTime;
  String? _selectedDay;
  final Map<String, List<Map<String, dynamic>>> _timetableData = {};
  late DatabaseHelper _databaseHelper; // Added

  @override
  void initState() {
    super.initState();
    _databaseHelper = DatabaseHelper(); // Initialize DatabaseHelper
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {
    await DatabaseHelper.initDatabase(); // Ensure database is initialized
  }

  Future<void> _selectTime(BuildContext context, bool isStartingTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartingTime) {
          _startingTime = picked;
        } else {
          _endingTime = picked;
        }
      });
    }
  }

  void _saveTask() {
    if (_selectedDay != null && _startingTime != null && _endingTime != null) {
      final taskData = {
        'day': _selectedDay,
        'startingTime': _formatTimeOfDay(_startingTime!),
        'endingTime': _formatTimeOfDay(_endingTime!),
        'task': _subjectController.text,
      };
      setState(() {
        if (_timetableData.containsKey(_selectedDay)) {
          _timetableData[_selectedDay]!.add(taskData);
        } else {
          _timetableData[_selectedDay!] = [taskData];
        }
        _startingTime = null;
        _endingTime = null;
        _subjectController.clear();
      });

      // Save to database
      DatabaseHelper.insertTimetable(taskData);
    }
  }

  String _formatTimeOfDay(TimeOfDay timeOfDay) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return DateFormat.Hm().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Timetable'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                hint: const Text('Select Day'),
                value: _selectedDay,
                onChanged: (String? value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                items: <String>[
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              ListTile(
                title: Text('Starting Time: ${_startingTime != null ? _startingTime!.format(context) : ''}'),
                trailing: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, true),
                ),
              ),
              ListTile(
                title: Text('Ending Time: ${_endingTime != null ? _endingTime!.format(context) : ''}'),
                trailing: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () => _selectTime(context, false),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _subjectController,
                  decoration: InputDecoration(labelText: 'Task'),
                ),
              ),
              ElevatedButton(
                onPressed: _saveTask,
                child: const Text('Save Task'),
              ),
              SizedBox(height: 20),
              ..._timetableData.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final task = entry.value[index];
                        return ListTile(
                          title: Text('${task['task']}'),
                          subtitle: Text('${task['startingTime']} - ${task['endingTime']}'),
                        );
                      },
                    ),
                    Divider(),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(CreateTimetable());
}
