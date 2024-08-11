import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer' as dev;
import 'package:intl/intl.dart';
import 'package:sen_app_latest/new_structure/teacher/dialogs/vivadialog.dart';
import 'package:sen_app_latest/new_structure/teacher/teachergrid.dart';

class TeacherViva extends StatefulWidget {
  const TeacherViva(
      {super.key, required this.classData, required this.username});
  final Map classData;
  final String username;

  @override
  TeacherVivaState createState() => TeacherVivaState();
}

class TeacherVivaState extends State<TeacherViva> {
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

        // Pass the formatted string to the buildViva function
        tempViva.add(
            buildViva(data['vivaname'], formattedStart, formattedEnd, doc.id));
      }
      setState(() {
        viva.addAll(tempViva);
      });
    } catch (e) {
      dev.log('Failed to fetch Viva details: $e');
    }
  }

  Widget buildViva(String vivaname, String start, String end, String vivaId) {
    return Card(
      // Dark background color
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
        title: Text(
          vivaname,
          style: const TextStyle(
            color: Colors.white, // Light text color
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Start: ',
                  style: TextStyle(
                    color: Colors.grey, // Subtle text color for labels
                  ),
                ),
                Text(
                  start,
                  style: const TextStyle(
                    color: Colors.white, // Light text color for data
                  ),
                ),
              ],
            ),
            Row(
              children: [
                const Text(
                  'End: ',
                  style: TextStyle(
                    color: Colors.grey, // Subtle text color for labels
                  ),
                ),
                Text(
                  end,
                  style: const TextStyle(
                    color: Colors.white, // Light text color for data
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.group,
            color: Color.fromARGB(255, 28, 178, 138), // Accent color for icon
          ), // Use a group icon to represent students
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TeacherGridPage(
                  vivaId: vivaId,
                ),
              ),
            );
          },
        ),
      ),
    )
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
          backgroundColor: Color.fromARGB(255, 0, 0, 0), // Dark blue background color
          title: Text(
            widget.classData['classname'],
            style: const TextStyle(
              color: Colors.white, // White text color
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white, // White icon color
              )),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              color: Color.fromARGB(255, 28, 178, 138), // Accent color for the icon
              onPressed: () async {
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return VivaDialog(
                      username: widget.username,
                      classData: widget.classData,
                    );
                  },
                ).then((result) {
                  if (result != null) {
                    // Handle the creation of the Viva with the returned data
                    dev.log('Viva created with: $result');
                    fetchVivaDetails();
                    // You can add the viva data to your list or send it to Firestore here
                  }
                });
              },
            ),
          ],
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
        backgroundColor: const Color(0xFF000000), // Pure black background color
      ),
    );
  }
}
