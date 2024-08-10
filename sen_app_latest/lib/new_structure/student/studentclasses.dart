import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/student/studentviva.dart';

class StudentClasses extends StatefulWidget {
  const StudentClasses({super.key, required this.username, required this.type});
  final String username;
  final String type;

  @override
  StudentClassesState createState() => StudentClassesState();
}

class StudentClassesState extends State<StudentClasses> {
  // List of classes
  List<Widget> classes = [];
  void joinClass() async {
    String? classCode;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Join Class"),
              content: TextField(
                decoration: const InputDecoration(labelText: "Class Code"),
                onChanged: (value) {
                  classCode = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (classCode != null) {
                      Navigator.of(context).pop({'classCode': classCode});
                    }
                  },
                  child: const Text("Join"),
                ),
              ],
            );
          },
        );
      },
    ).then((result) async {
      if (result != null) {
        String classCode = result['classCode'];

        // Fetch the class document based on the class code
        QuerySnapshot classSnapshot = await FirebaseFirestore.instance
            .collection('classes')
            .where('code', isEqualTo: classCode)
            .get();

        if (classSnapshot.docs.isNotEmpty) {
          DocumentSnapshot classDoc = classSnapshot.docs.first;
          String classId = classDoc.id; // Get the class document ID
          Map<String, dynamic> classData =
              classDoc.data() as Map<String, dynamic>;

          // Fetch the user's document based on username and type
          QuerySnapshot userSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: widget.username)
              .where('type', isEqualTo: 'student')
              .get();

          if (userSnapshot.docs.isNotEmpty) {
            DocumentSnapshot userDoc = userSnapshot.docs.first;
            String userId = userDoc.id; // Get the user's document ID

            // Update the student's document to add the class ID to their list
            await userDoc.reference.update({
              'classes': FieldValue.arrayUnion([classId])
            });

            // Update the class document to add the student to the 'students' list
            DocumentReference classDocRef =
                FirebaseFirestore.instance.collection('classes').doc(classId);
            await classDocRef.update({
              'students': FieldValue.arrayUnion([userId])
            });

            // Check for viva field in the class data
            if (classData.containsKey('viva')) {
              List<dynamic> vivaIds = classData['viva'];
              for (String vivaId in vivaIds) {
                DocumentReference vivaDocRef =
                    FirebaseFirestore.instance.collection('viva').doc(vivaId);

                await vivaDocRef.update({
                  'students.${widget.username}': {
                    'score': 0,
                    'status': 'not attempted'
                  }
                });
              }
            }

            debugPrint('Joined class with code: $classCode');
            fetchClasses(); // Refresh the class list
          } else {
            debugPrint(
                'User with username ${widget.username} and type "student" not found.');
          }
        } else {
          debugPrint('Class with code $classCode does not exist.');
        }
      }
    });
  }

  Widget buildClasses(String classname, String description, classData) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentViva(
                classData: classData,
                username: widget.username,
              ),
            ),
          );
        },
        title: Text(classname),
        subtitle: Text(description),
        trailing: GestureDetector(
          child: Icon(
            Icons.arrow_forward,
            color: Colors.red.shade600,
          ),
          onTap: () {
            debugPrint("arrow forward tapped");
          },
        ),
      ),
    );
  }

  Future<void> fetchClasses() async {
    List<Widget> tempClasses = [];
    classes = [];

    try {
      // Get the teacher document
      QuerySnapshot teacherSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .where('type', isEqualTo: 'student')
          .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        DocumentSnapshot teacherDoc = teacherSnapshot.docs.first;
        Map<String, dynamic> teacherData =
            teacherDoc.data() as Map<String, dynamic>;

        // Get the list of class IDs
        List<dynamic> classIds = teacherData['classes'] ?? [];

        // Fetch each class by its document ID
        for (String classId in classIds) {
          DocumentSnapshot classDoc = await FirebaseFirestore.instance
              .collection('classes')
              .doc(classId)
              .get();

          if (classDoc.exists) {
            var data = classDoc.data() as Map<String, dynamic>;
            tempClasses.add(
                buildClasses(data['classname'], data['description'], data));
          }
        }
      }

      setState(() {
        classes.addAll(tempClasses);
      });
    } catch (e) {
      log('Failed to fetch classes: $e');
    }
  }

  Future<void> createClass(Map<String, dynamic> classData) async {
    try {
      DocumentReference classRef =
          await FirebaseFirestore.instance.collection('classes').add(classData);

      // Check for viva field in the class data
      if (classData.containsKey('viva')) {
        List<dynamic> vivaIds = classData['viva'];
        for (String vivaId in vivaIds) {
          DocumentReference vivaDocRef =
              FirebaseFirestore.instance.collection('viva').doc(vivaId);

          await vivaDocRef.update({
            'students': FieldValue.arrayUnion([widget.username])
          });
        }
      }

      debugPrint('Class created with ID: ${classRef.id}');
    } catch (e) {
      log('Failed to create class: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.greenAccent,
          title: const Text('Classes'),
          actions: [
            IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              icon: const Icon(Icons.add),
              onPressed: () async {
                joinClass();
                fetchClasses(); // Refresh the class list after creating a class
              },
            )
          ],
        ),
        body: Center(
          child: ListView.builder(
            itemCount: classes.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: classes[index],
              );
            },
          ),
        ),
      ),
    );
  }
}
