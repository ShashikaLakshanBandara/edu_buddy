import 'package:flutter/material.dart';
import 'package:edu_buddy/Database/database_helper.dart';

class ViewTimeTable extends StatefulWidget {
  const ViewTimeTable({Key? key}) : super(key: key);

  @override
  _ViewTimeTableState createState() => _ViewTimeTableState();
}

class _ViewTimeTableState extends State<ViewTimeTable> {
  List<Map<String, dynamic>>? _timeTable;

  @override
  void initState() {
    super.initState();
    _fetchTimeTable();
  }

  Future<void> _fetchTimeTable() async {
    final timetable = await DatabaseHelper.getAllTimetable();
    setState(() {
      _timeTable = timetable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Timetable'),
      ),
      body: _timeTable != null && _timeTable!.isNotEmpty
          ? ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: _timeTable!.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16.0),
        itemBuilder: (context, index) {
          final timetableEntry = _timeTable![index];
          return Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${timetableEntry['day']}',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Task: ${timetableEntry['task']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Time: ${timetableEntry['startingTime']} - ${timetableEntry['endingTime']}',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Navigate to edit screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditTimeTable(entry: timetableEntry),
                            ),
                          );
                        },
                        child: Text('Edit'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      )
          : Center(
        child: Text(
          'No timetable data available.',
          style: TextStyle(fontSize: 18.0),
        ),
      ),
    );
  }
}

class EditTimeTable extends StatefulWidget {
  final Map<String, dynamic> entry;

  const EditTimeTable({Key? key, required this.entry}) : super(key: key);

  @override
  _EditTimeTableState createState() => _EditTimeTableState();
}

class _EditTimeTableState extends State<EditTimeTable> {
  late TextEditingController _taskController;
  late TextEditingController _startingTimeController;
  late TextEditingController _endingTimeController;

  @override
  void initState() {
    super.initState();
    _taskController = TextEditingController(text: widget.entry['task']);
    _startingTimeController = TextEditingController(text: widget.entry['startingTime']);
    _endingTimeController = TextEditingController(text: widget.entry['endingTime']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.entry['day']} Timetable'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextFormField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Enter task',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Starting Time:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextFormField(
              controller: _startingTimeController,
              decoration: InputDecoration(
                hintText: 'Enter starting time',
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Ending Time:',
              style: TextStyle(fontSize: 18.0),
            ),
            TextFormField(
              controller: _endingTimeController,
              decoration: InputDecoration(
                hintText: 'Enter ending time',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Update timetable entry in database
                DatabaseHelper.updateTimetable({
                  'id': widget.entry['id'],
                  'task': _taskController.text,
                  'startingTime': _startingTimeController.text,
                  'endingTime': _endingTimeController.text,
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    _startingTimeController.dispose();
    _endingTimeController.dispose();
    super.dispose();
  }
}
