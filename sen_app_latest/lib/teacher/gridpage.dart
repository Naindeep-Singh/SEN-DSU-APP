import 'package:flutter/material.dart';
import 'package:sen_app_latest/teacher/teachertopicpage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Griddpage extends StatefulWidget {
  const Griddpage(
      {super.key, required this.numberOfStudents, required this.data});
  final int numberOfStudents;
  final Map data;
  @override
  State<Griddpage> createState() => _GriddpageState();
}

class _GriddpageState extends State<Griddpage> {
  Map<int, Map<String, dynamic>> masterStudDict = {};
  Map data = {};

  @override
  void initState() {
    super.initState();
    for (var i = 1; i <= widget.numberOfStudents; i++) {
      masterStudDict[i] = {'name': 'Student $i', 'score': 0, 'present': false};
    }
    debugPrint("\x1B[33m ${widget.data} \x1B[0m");
    debugPrint("\x1B[0m");
  }

  Future<void> _navigateAndUpdateScore(BuildContext context, int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeacherTp(
          data: widget.data,
          title: "Test 1",
        ),
      ),
    );

    if (result != null) {
      setState(() {
        masterStudDict[index]!['score'] = result;
        masterStudDict[index]!['present'] =
            true; // Mark as present when the score is updated
      });
      debugPrint("\x1B[33m${masterStudDict[index]!['present']} \x1B[0m");
    }
  }

  Future<void> sendstudData() async {
    final url = Uri.parse('http://192.168.0.112:5000/storedata');
    final headers = {
      'Content-Type': 'application/json',
    };
    final Map data = masterStudDict;

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON.
        final responseData = json.decode(response.body);
        debugPrint('Response data: $responseData');
      } else {
        // If the server does not return a 200 OK response, throw an exception.
        debugPrint('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending data: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
    sendstudData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Student Grid Page'),
            IconButton(
                onPressed: () {
                  sendstudData();
                },
                icon: const Icon(Icons.upload_file))
          ],
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, // 3 columns
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: widget.numberOfStudents,
        itemBuilder: (context, index) {
          int studentIndex = index + 1;
          bool isTestCompleted = masterStudDict[studentIndex]!['present'];
          int score = masterStudDict[studentIndex]!['score'];

          return GestureDetector(
            onTap: () {
              _navigateAndUpdateScore(context, studentIndex);
            },
            child: Card(
              color: isTestCompleted
                  ? Colors.green.shade50
                  : Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
                side: const BorderSide(color: Colors.deepPurple, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Center(
                      child: Text(
                        'USN $studentIndex',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Container(
                      width: 75,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.deepPurple, width: 1),
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StatefulBuilder(
                              builder: (BuildContext context, setState) {
                                return Text(
                                  'Score: $score',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.deepPurple,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 7),
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color:
                                    isTestCompleted ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
