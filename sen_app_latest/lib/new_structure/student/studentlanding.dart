import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/document_upload/documentupload.dart';
import 'package:sen_app_latest/new_structure/student/studentclasses.dart';

class StudentLanding extends StatefulWidget {
  const StudentLanding({super.key, required this.username, required this.type, required String email});
  final String username;
  final String type;

  @override
  State<StudentLanding> createState() => _StudentLandingState();
}

class _StudentLandingState extends State<StudentLanding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DocumentUpload(
                      username: widget.username,
                    ),
                  ),
                );
              },
              child: const Text('Doc Upload')),
          ElevatedButton(
              onPressed: () {
                log(widget.type);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentClasses(
                      username: widget.username,
                      type: widget.type,
                    ),
                  ),
                );
              },
              child: const Text('Classes'))
        ],
      ),
    );
  }
}
