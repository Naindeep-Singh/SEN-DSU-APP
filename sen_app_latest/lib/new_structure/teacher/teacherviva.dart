import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TeacherViva extends StatefulWidget {
  const TeacherViva({super.key, required this.classData});
  final Map classData;

  @override
  TeacherVivaState createState() => TeacherVivaState();
}

class TeacherVivaState extends State<TeacherViva> {
  // List of classes
  final List<Map<String, String>> vivas = [
    {
      'vivaName': 'Viva 1',
      'start': '2024-08-07 10:40',
      'end': '2024-08-09 10:40'
    },
    {
      'vivaName': 'Viva 2',
      'start': '2024-08-07 10:40',
      'end': '2024-08-09 10:40'
    },
    {
      'vivaName': 'Viva 3',
      'start': '2024-08-07 10:40',
      'end': '2024-08-09 10:40'
    },
    {
      'vivaName': 'Viva 4',
      'start': '2024-08-07 10:40',
      'end': '2024-08-09 10:40'
    },
  ];

  void _addViva() async {
    String? title;
    DateTime? startDate;
    DateTime? endDate;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Add Viva"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: const InputDecoration(labelText: "Title"),
                    onChanged: (value) {
                      title = value;
                    },
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "Start Date"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            startDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    controller: TextEditingController(
                      text: startDate != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(startDate!)
                          : '',
                    ),
                  ),
                  TextField(
                    decoration: const InputDecoration(labelText: "End Date"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                        );
                        if (pickedTime != null) {
                          setState(() {
                            endDate = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );
                          });
                        }
                      }
                    },
                    controller: TextEditingController(
                      text: endDate != null
                          ? DateFormat('yyyy-MM-dd HH:mm').format(endDate!)
                          : '',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    if (title != null && startDate != null && endDate != null) {
                      setState(
                          () {}); // Only to update local state in the dialog
                      Navigator.of(context).pop(
                          {'title': title, 'start': startDate, 'end': endDate});
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) {
      if (result != null) {
        setState(() {
          vivas.add({
            'vivaName': result['title'],
            'start': DateFormat('yyyy-MM-dd HH:mm').format(result['start']),
            'end': DateFormat('yyyy-MM-dd HH:mm').format(result['end']),
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          title: const Text('Viva'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _addViva,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: vivas.map((vivaInfo) {
              return Card(
                margin: const EdgeInsets.all(10.0),
                child: ListTile(
                  title: Text(vivaInfo['vivaName']!),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('Start: '),
                          Text(vivaInfo['start']!),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('End: '),
                          Text(vivaInfo['end']!),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
