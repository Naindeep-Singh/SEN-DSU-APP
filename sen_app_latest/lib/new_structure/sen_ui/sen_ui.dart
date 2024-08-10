import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sen_app_latest/new_structure/document_upload/documentupload.dart';
import 'package:sen_app_latest/new_structure/community/community.dart';
import 'package:sen_app_latest/new_structure/profile/profile.dart';
import 'package:sen_app_latest/new_structure/student/studentclasses.dart';
import 'package:sen_app_latest/new_structure/student/student_session.dart'; 
import 'package:sen_app_latest/new_structure/teacher/teacherlanding.dart'; 
import 'package:sen_app_latest/new_structure/teacher/session/session.dart'; 

class SENPage extends StatefulWidget {
  final String username;
  final String userType;

  const SENPage({super.key, required this.username, required this.userType});

  @override
  SENPageState createState() => SENPageState();
}

class SENPageState extends State<SENPage> {
  int _selectedIndex = 0; // Default index to the first tab

  // List of widgets corresponding to each bottom navigation item
  List<Widget> get _widgetOptions {
    if (widget.userType == 'teacher') {
      return [
        TeacherLanding(
            username: widget.username), // Teacher's Landing Page (Groups)
        SessionLanding(
          username: widget.username,
          email: '',
        ), // Teacher's Session page (Exam)
        CommunityPage(username: widget.username),
        ProfilePage(userType: widget.userType, username: widget.username),
      ];
    } else {
      return [
        StudentClasses(
          username: widget.username,
          type: widget.userType,
        ), // Student's Landing Page (Groups)
        StudentSession(
          username: widget.username,
          email: '',
        ), // New Page for Student Session
        DocumentUpload(
            username:
                widget.username), // Viva - Ai linked to DocumentUpload (Exam)
        CommunityPage(username: widget.username),
        ProfilePage(userType: widget.userType, username: widget.username),
      ];
    }
  }

  // Bottom navigation bar items configuration
  List<BottomNavigationBarItem> get _bottomNavBarItems {
    if (widget.userType == 'teacher') {
      return const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Exam', // Teachers see "Groups" here
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Groups', // Teachers see "Exam" here
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    } else {
      return const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Groups', // Students see "Groups" here
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Session', // New button for Student Session
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.description),
          label: 'Viva - Ai', // Students see "Viva - Ai" here
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group),
          label: 'Community',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Row(
          children: [
            Text(
              'SEN',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: <Color>[
                      Color(0xFF00B4DB),
                      Color(0xFF0083B0),
                    ],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
            ),
            const SizedBox(width: 8),
            Lottie.network(
              'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
              height: 40,
              width: 40,
            ),
          ],
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavBarItems,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        backgroundColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 14,
        unselectedFontSize: 12,
        showUnselectedLabels: false,
      ),
    );
  }
}
