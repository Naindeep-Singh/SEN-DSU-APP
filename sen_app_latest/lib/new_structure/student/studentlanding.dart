import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/document_upload/documentupload.dart';

class StudentLanding extends StatefulWidget {
  const StudentLanding({super.key, required this.username});
  final String username;

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
                    builder: (context) => Documentupload(
                      username: widget.username,
                    ),
                  ),
                );
              },
              child: const Text('Doc Upload'))
        ],
      ),
    );
  }
}
