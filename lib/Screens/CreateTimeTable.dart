import 'package:flutter/material.dart';

class Createtimetable extends StatefulWidget {
  const Createtimetable({Key? key}) : super(key: key);

  @override
  State<Createtimetable> createState() => _CreatetimetableState();
}

class _CreatetimetableState extends State<Createtimetable> {
  List<String> freeTimePeriod = [];
  double totalFreeTime = 0.0;

  TextEditingController subjectCounts = TextEditingController();

  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  TimeOfDay? startingTime;
  TimeOfDay? endingTime;

  Future<void> _selectStartingTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        startingTime = picked;
      });
    }
  }

  Future<void> _selectEndingTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        endingTime = picked;
      });
    }
  }

  String? _selectedDay;

  String getFormattedTime(TimeOfDay? time) {
    if (time == null) {
      return '';
    }
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  List<TextEditingController> _subjectControllers = [];
  List<Widget> _subjectFields = [];

  void _generateSubjectFields(int count) {
    _subjectControllers = List.generate(count, (index) => TextEditingController());
    _subjectFields = List.generate(count, (index) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextField(
          controller: _subjectControllers[index],
          decoration: InputDecoration(labelText: 'Subject ${index + 1}'),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Create Time Table'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              DropdownButton<String>(
                hint: Text('Select a day'),
                value: _selectedDay,
                items: _daysOfWeek.map((String day) {
                  return DropdownMenuItem<String>(
                    value: day,
                    child: Text(day),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDay = newValue;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _selectStartingTime(context),
                    child: Text(startingTime != null
                        ? getFormattedTime(startingTime)
                        : 'Starting Time'),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectEndingTime(context),
                    child: Text(endingTime != null
                        ? getFormattedTime(endingTime)
                        : 'Ending Time'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final String startTime = getFormattedTime(startingTime);
                      final String endTime = getFormattedTime(endingTime);
                      if (startTime.isNotEmpty && endTime.isNotEmpty) {
                        _calculateTotalFreeTime(startingTime!, endingTime!);
                        freeTimePeriod.add('$startTime-$endTime');
                        print(freeTimePeriod);
                      }
                    },
                    child: const Text('Add Time Period'),
                  ),
                ],
              ),
              Text('Total Free Time: ${totalFreeTime.toStringAsFixed(2)} hours'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: subjectCounts,
                      decoration: const InputDecoration(labelText: 'Subject Counts'),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final int count = int.tryParse(subjectCounts.text) ?? 0;
                      if (count > 0) {
                        setState(() {
                          _generateSubjectFields(count);
                        });
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
              ..._subjectFields,
              if (_subjectFields.isNotEmpty)
                ElevatedButton(
                  onPressed: () {
                    for (var controller in _subjectControllers) {
                      print('Subject: ${controller.text}');
                    }
                    _organizeTable();
                    // Handle further actions with the subject names here
                  },
                  child: const Text('OK'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _organizeTable() {
    double startingTime = 8;
    double endingTime = 10;

    double timeForOneSubject = totalFreeTime/double.parse(subjectCounts.text);
    for(double timeDuration = 0.0; timeDuration<=(timeForOneSubject*60);timeDuration+=1){




      //print('Duration : $timeDuration');
    }


    //print('timefor one subject= $timeForOneSubject');
  }

  void _calculateTotalFreeTime(TimeOfDay startTime, TimeOfDay endTime) {
    final int startMinutes = startTime.hour * 60 + startTime.minute;
    final int endMinutes = endTime.hour * 60 + endTime.minute;
    final double differenceInMinutes = (endMinutes - startMinutes).toDouble();
    setState(() {
      totalFreeTime += differenceInMinutes / 60; // Convert minutes to hours
      print('Total free time : $totalFreeTime');
    });
  }
}
