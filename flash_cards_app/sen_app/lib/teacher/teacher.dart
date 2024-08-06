import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sen_app/teacher/gridpage.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key, required this.data});
  final Map data;

  @override
  TeacherPageState createState() => TeacherPageState();
}

class TeacherPageState extends State<TeacherPage> {
  Map data = {};
  int _selectedStudents = 25;
  Future<void> sendGet() async {
    final Uri url = Uri.parse('http://192.168.0.112:5000/t_get_document');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 24));
      if (response.statusCode == 200) {
        data = jsonDecode(response.body);
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // sendGet();
    data = widget.data;
    debugPrint("\x1B[31m $data \x1B[0m");
    debugPrint("\x1B[0m");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teacher Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: _selectedStudents,
              items: <int>[25, 50, 75, 100].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Students'),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedStudents = newValue!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              onPressed: () {
                debugPrint("${data["Neural Networks"]}");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Griddpage(
                      numberOfStudents: _selectedStudents,
                      data: data,
                    ),
                  ),
                );
              },
              child: const Text('Proceed '),
            ),
          ],
        ),
      ),
    );
  }
}
