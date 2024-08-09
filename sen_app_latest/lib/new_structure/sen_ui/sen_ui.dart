import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/document_upload/documentupload.dart';
import 'package:sen_app_latest/new_structure/profile/profile.dart';
import 'package:sen_app_latest/new_structure/student/studentlanding.dart';

class SENPage extends StatefulWidget {
  final String username;
  final String userType;

  const SENPage({Key? key, required this.username, required this.userType})
      : super(key: key);

  @override
  _SENPageState createState() => _SENPageState();
}

class _SENPageState extends State<SENPage> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions => [
        StudentLanding(username: widget.username), // Home Page (Classroom)
        DocumentUpload(username: widget.username), // Viva Page (Document Upload)
        ProfilePage(
            userType: widget.userType, username: widget.username), // Profile Page
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildFloatingActionButton() {
    if (_selectedIndex == 0) {
      return FloatingActionButton(
        onPressed: () {
          // Handle creation action for Classroom
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.black),
      );
    } else {
      return Container(); // No FAB on other pages
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'SEN',
          style: TextStyle(
            color: Colors.teal,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.teal),
            onPressed: () {
              // Handle search action
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.teal),
            onPressed: () {
              // Handle more action
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Classroom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Viva',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
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
