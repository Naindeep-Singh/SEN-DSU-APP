import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:sen_app_latest/new_structure/student/studentquestions.dart';

class StudentViva extends StatefulWidget {
  const StudentViva(
      {super.key, required this.classData, required this.username});
  final Map classData;
  final String username;

  @override
  StudentVivaState createState() => StudentVivaState();
}

class StudentVivaState extends State<StudentViva> {
  // List of vivas
  List<Widget> viva = [];

  Future<void> fetchVivaDetails() async {
    List<Widget> tempViva = [];
    viva = [];

    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('viva')
          .where('teacher', isEqualTo: widget.classData['teacher'])
          .where('code', isEqualTo: widget.classData['code'])
          .get();

      List<DocumentSnapshot> docs = querySnapshot.docs;
      dev.log('$docs');

      for (var doc in docs) {
        var data = doc.data() as Map<String, dynamic>;

        // Convert the Firestore timestamp to a DateTime object
        Timestamp startTimestamp = data['start'] as Timestamp;
        Timestamp endTimestamp = data['end'] as Timestamp;

        DateTime startDate = startTimestamp.toDate();
        DateTime endDate = endTimestamp.toDate();

        // Format the DateTime object to a string
        String formattedStart =
            DateFormat('dd-MM-yy HH:mm:ss').format(startDate);
        String formattedEnd = DateFormat('dd-MM-yy HH:mm:ss').format(endDate);

        // Determine if the button should be enabled based on the start date and student status
        bool isButtonEnabled = DateTime.now().isAfter(startDate);

        // Check the student's status in the current viva document
        String studentStatus =
            data['students']?[widget.username]?['status'] ?? 'pending';

        // Pass the formatted string to the buildViva function
        tempViva.add(buildViva(data['vivaname'], formattedStart, formattedEnd,
            doc.id, isButtonEnabled, data, studentStatus));
      }
      setState(() {
        viva.addAll(tempViva);
      });
    } catch (e) {
      dev.log('Failed to fetch Viva details: $e');
    }
  }

  Widget buildViva(String vivaname, String start, String end, String vivaId,
      bool isButtonEnabled, Map<String, dynamic> data, String studentStatus) {
    // Determine the button state and text based on the student's status
    bool isStudentDone = studentStatus == 'done';
    String buttonText = isStudentDone ? 'Done' : 'Start Viva';
    bool buttonEnabled = isButtonEnabled && !isStudentDone;

    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ListTile(
        title: Text(vivaname),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Start: '),
                Text(start),
              ],
            ),
            Row(
              children: [
                const Text('End: '),
                Text(end),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: buttonEnabled
              ? () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentQuestions(
                        data: jsonDecode(data['vivatext']),
                        name: data['class'],
                        vivaId: vivaId,
                        username: widget.username,
                      ),
                    ),
                  );
                  fetchVivaDetails();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonEnabled ? Colors.green : Colors.grey,
          ),
          child: Text(buttonText),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchVivaDetails();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          title: Text(widget.classData['classname']),
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back)),
        ),
        body: Center(
          child: ListView.builder(
            itemCount: viva.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: viva[index],
              );
            },
          ),
        ),
      ),
    );
  }
}