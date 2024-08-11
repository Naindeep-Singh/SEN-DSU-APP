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
              
              backgroundColor: Color.fromARGB(255, 21, 78, 60), // Dark background color
              title: const Text(
                "Join Class",
                style: TextStyle(color: Colors.white), // Light text color
              ),
              content: TextField(
                decoration: const InputDecoration(
                  labelText: "Class Code",
                  labelStyle: TextStyle(color: Colors.grey), // Subtle text color
                ),
                style: const TextStyle(color: Colors.white), // Light text color
                onChanged: (value) {
                  classCode = value;
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.orange), // Accent color
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (classCode != null) {
                      Navigator.of(context).pop({'classCode': classCode});
                    }
                  },
                  child: const Text(
                    "Join",
                    style: TextStyle(color: Colors.orange), // Accent color
                  ),
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
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[850]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0), // Match the Card's shape
      ),
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
        title: Text(
          classname,
          style: const TextStyle(
            color: Colors.white, // Light text color
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(
            color: Colors.grey, // Subtle text color for description
          ),
        ),
        trailing: GestureDetector(
          child: Icon(
            Icons.arrow_forward,
            color: Color.fromARGB(255, 28, 178, 138), // Accent color for icon
          ),
          onTap: () {
            debugPrint("arrow forward tapped");
          },
        ),
      ),
    )
    
    );
  }

  Future<void> fetchClasses() async {
    List<Widget> tempClasses = [];
    classes = [];

    try {
      // Get the student document
      QuerySnapshot studentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: widget.username)
          .where('type', isEqualTo: 'student')
          .get();

      if (studentSnapshot.docs.isNotEmpty) {
        DocumentSnapshot studentDoc = studentSnapshot.docs.first;
        Map<String, dynamic> studentData =
            studentDoc.data() as Map<String, dynamic>;

        // Get the list of class IDs
        List<dynamic> classIds = studentData['classes'] ?? [];

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
          backgroundColor: Color.fromARGB(255, 0, 0, 0), // Dark blue background color
          title: const Text(
            'Classes',
            style: TextStyle(
              color: Colors.white, // White text color
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Color.fromARGB(255, 28, 178, 138), // Accent color for the icon
              onPressed: () async {
                joinClass();
                fetchClasses(); // Refresh the class list after joining a class
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
        backgroundColor: const Color(0xFF000000), // Pure black background color
      ),
    );
  }
}
