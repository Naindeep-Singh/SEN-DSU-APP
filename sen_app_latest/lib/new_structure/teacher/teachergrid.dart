import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherGridPage extends StatefulWidget {
  const TeacherGridPage({super.key, required this.vivaId});
  final String vivaId;

  @override
  State<TeacherGridPage> createState() => _TeacherGridPageState();
}

class _TeacherGridPageState extends State<TeacherGridPage> {
  Map<int, Map<String, dynamic>> masterStudDict = {};
  Map<String, dynamic> vivaData = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('viva')
          .doc(widget.vivaId)
          .get();

      if (doc.exists) {
        vivaData = doc.data() as Map<String, dynamic>;
        Map<String, dynamic> students = vivaData['students'] ?? {};

        int index = 1;
        students.forEach((username, details) {
          masterStudDict[index] = {
            'name': username,
            'score': details['score'] ?? 0,
            'present': details['status'] == 'done',
          };
          index++;
        });
        log('${vivaData['students']}');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Failed to fetch student data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Set the AppBar background to black
        title: const Text(
          'Student Grid Page',
          style: TextStyle(color: Colors.white), // Set the title color to white
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set the back button color to white
        ),
      ),
      backgroundColor: Colors.black, // Set the page background to black
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, // 3 columns
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
              ),
              itemCount: masterStudDict.length,
              itemBuilder: (context, index) {
                int studentIndex = index + 1;
                bool isTestCompleted = masterStudDict[studentIndex]!['present'];
                int score = masterStudDict[studentIndex]!['score'];
                String name = masterStudDict[studentIndex]!['name'];

                return GestureDetector(
                  child: Card(
                    color: isTestCompleted
                        ? Colors.green.shade50
                        : Colors.red.shade50, // Updated color for not done
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
                              name,
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
                                  Text(
                                    'Score: $score',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.deepPurple,
                                    ),
                                  ),
                                  const SizedBox(width: 7),
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: isTestCompleted
                                          ? Colors.green
                                          : Colors.red,
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
