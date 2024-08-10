import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package for animation
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
  bool isLoading = false; // Variable to handle the loading state
  bool isDeleting = false; // Variable to handle the deleting state

  Widget buildClasses(String classname, String description, String docId) {
    return Card(
      margin: const EdgeInsets.all(10.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeacherViva(
                classData: {
                  'classname': classname,
                  'description': description,
                  'docId': docId,
                },
                username: widget.username,
              ),
            ),
          );
        },
        title: Text(
          classname,
          style: TextStyle(
            color: Colors.teal.shade900,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Text(description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.red.shade600,
              ),
              onTap: () {
                _deleteClass(docId);
              },
            ),
            const SizedBox(width: 10),
            GestureDetector(
              child: Icon(
                Icons.arrow_forward,
                color: Colors.teal.shade600,
              ),
              onTap: () {
                debugPrint("arrow forward tapped");
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> fetchClasses() async {
    setState(() {
      isLoading = true;
    });
    List<Widget> tempClasses = [];
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('teacher', isEqualTo: widget.username)
          .get();
      List<DocumentSnapshot> docs = querySnapshot.docs;

      for (var doc in docs) {
        var data = doc.data() as Map<String, dynamic>;
        tempClasses.add(buildClasses(data['classname'], data['description'], doc.id));
      }
      setState(() {
        classes = tempClasses;
        isLoading = false;
      });
    } catch (e) {
      log('Failed to fetch classes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _deleteClass(String docId) async {
    setState(() {
      isDeleting = true; // Start deleting animation
    });

    try {
      await FirebaseFirestore.instance.collection('classes').doc(docId).delete();
      setState(() {
        classes.removeWhere((widget) {
          final key = widget.key as ValueKey<String>?;
          return key?.value == docId;
        });
        isDeleting = false; // Stop deleting animation
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Class deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Failed to delete class: $e');
      setState(() {
        isDeleting = false; // Stop deleting animation
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete class'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> _addNewClass() async {
    setState(() {
      isLoading = true; // Start loading animation
    });

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return ClassFormDialog(
          username: widget.username,
        );
      },
    );

    // Fetch the updated list of classes after adding a new one
    await fetchClasses();

    setState(() {
      isLoading = false; // Stop loading animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Persistent background Lottie animation
            Center(
              child: Lottie.network(
                'https://lottie.host/0a0023ec-5f54-413c-a606-379c31b96aa3/mlPolAAUBJ.json',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.72,
                height: MediaQuery.of(context).size.height * 0.72,
              ),
            ),
            Center(
              child: isLoading || isDeleting
                  ? Lottie.network(
                      'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                      width: 150,
                      height: 150,
                    )
                  : classes.isNotEmpty
                      ? ListView.builder(
                          itemCount: classes.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: classes[index],
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            "No classes available",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.teal,
                child: const Icon(Icons.add),
                onPressed: _addNewClass, // Open the dialog to add a new class
              ),
            ),
          ],
        ),
      ),
    );
  }
}
