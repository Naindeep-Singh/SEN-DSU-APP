import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/teacher/dialogs/classcreatedioalog.dart';
import 'package:sen_app_latest/new_structure/teacher/teacherviva.dart';

class TeacherLanding extends StatefulWidget {
  const TeacherLanding({super.key, required this.username});
  final String username;

  @override
  TeacherLandingState createState() => TeacherLandingState();
}

class TeacherLandingState extends State<TeacherLanding> {
  // List of classes
  List<Widget> classes = [];
  
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
              builder: (context) => TeacherViva(
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
            fontSize: 14,
          ),
        ),
        trailing: GestureDetector(
          child: Icon(
            Icons.arrow_forward,
            color: Color.fromARGB(255, 28, 146, 110), // Accent color for arrow
          ),
          onTap: () {
            debugPrint("arrow forward tapped");
          },
        ),
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
          .where('type', isEqualTo: 'teacher')
          .get();

      if (teacherSnapshot.docs.isNotEmpty) {
        DocumentSnapshot teacherDoc = teacherSnapshot.docs.first;
        Map<String, dynamic> teacherData = teacherDoc.data() as Map<String, dynamic>;

        // Get the list of class IDs
        List<dynamic> classIds = teacherData['classes'] ?? [];

        // Fetch each class by its document ID
        for (String classId in classIds) {
          DocumentSnapshot classDoc = await FirebaseFirestore.instance.collection('classes').doc(classId).get();

          if (classDoc.exists) {
            var data = classDoc.data() as Map<String, dynamic>;
            tempClasses.add(buildClasses(data['classname'], data['description'], data));
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
              color: Color.fromARGB(255, 0, 208, 156), // Accent color for the icon
              onPressed: () async {
                fetchClasses();
                await showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return ClassFormDialog(
                      username: widget.username,
                    );
                  },
                );
                fetchClasses();
              },
            ),
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
        backgroundColor: Color.fromARGB(255, 0, 0, 0), // Darker background color
      ),
    );
  }
}
