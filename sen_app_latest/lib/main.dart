import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sen_app_latest/student/flipcard.dart';
import 'package:sen_app_latest/student/questionspage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sen_app_latest/startscreen/splashscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sen App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.data});
  final String title;
  final Map data;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<void> sendGet() async {
    List<Widget> temptopics = [];

    final Uri url = Uri.parse('http://192.168.0.103:5000/get_document');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 24));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        for (var name in data['names']) {
          temptopics.add(buildTopics(name, data[name]));
        }
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
      }
      setState(() {
        topics.addAll(temptopics);
      });
    } catch (e) {
      debugPrint('Error occurred: $e');
    }
  }

  Widget buildTopics(String name, Map data) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade400, width: 1),
      ),
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6), // Reduced margin for smaller appearance
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Smaller padding
        leading: const Icon(
          Icons.batch_prediction,
          color: Colors.deepPurple,
        ),
        title: Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15, // Slightly smaller font size
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        onTap: () {
          if (ans) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FlipCardPage(
                  data: data,
                ),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuestionsPage(
                  data: data,
                  name: name,
                  ans: ans,
                ),
              ),
            );
          }
        },
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  Map data = {};
  List<Widget> topics = [];
  bool ans = false;

  @override
  void initState() {
    super.initState();
    List<Widget> temptopics = [];

    data = widget.data;

    widget.data.forEach((key, value) {
      temptopics.add(buildTopics(key, value));
    });

    setState(() {
      topics.addAll(temptopics);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Text(widget.title),
        actions: [
          FlutterSwitch(
            activeText: "ANS",
            inactiveText: "MCQ",
            value: ans,
            activeTextColor: Colors.black,
            valueFontSize: 10.0,
            activeColor: Colors.grey.shade700,
            inactiveTextColor: Colors.grey.shade500,
            inactiveColor: Colors.black,
            width: 65,
            showOnOff: true,
            onToggle: (val) {
              setState(() {
                ans = val;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: topics.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: topics[index],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendGet,
        tooltip: 'Fetch Topics',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
