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
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherViva(
                classData: classData,
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
    List<Widget> tempclasses = [];
    classes = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('classes')
        .where('teacher', isEqualTo: widget.username)
        .get();
    List<DocumentSnapshot> docs = querySnapshot.docs;
    log('$docs');

    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      tempclasses
          .add(buildClasses(data['classname'], data['description'], data));
    }
    setState(() {
      classes.addAll(tempclasses);
    });
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
