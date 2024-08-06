import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sen_app_latest/student/questionspage.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sen_app_latest/startscreen/splashscreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: const MyHomePage(title: 'Topics'),
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

    final Uri url = Uri.parse('http://192.168.0.112:5000/get_document');

    try {
      // Send the GET request
      final response = await http.get(url).timeout(const Duration(seconds: 24));

      // Check for a successful response
      if (response.statusCode == 200) {
        debugPrint('1');
        final data = jsonDecode(response.body);
        debugPrint(response.body);
        for (var name in data['names']) {
          debugPrint('10');
          temptopics.add(buildTopics(name, data[name]));
        }
        debugPrint('3');
      } else {
        // Handle non-successful response
        debugPrint('Request failed with status: ${response.statusCode}');
      }
      setState(() {
        topics.addAll(temptopics);
      });
    } catch (e) {
      // Handle any errors that occur
      debugPrint('Error occurred: $e');
    }
  }

  Widget buildTopics(String name, Map data) {
    return ListTile(
      // key: Key(name),
      leading: const Icon(
        Icons.batch_prediction,
        color: Colors.amber,
      ),
      title: Center(
        child: Text(
          name,
          style: const TextStyle(
            fontSize: 15,
          ),
        ),
      ),
      onTap: () {
        debugPrint("$name is the topic");
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
      },
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.black, width: 2),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25))),
      trailing: GestureDetector(
        child: Icon(
          Icons.arrow_forward,
          color: Colors.red.shade600,
        ),
        onTap: () async {
          debugPrint("gay");
        },
      ),
    );
  }

  Map data = {};

  @override
  void initState() {
    super.initState();
    List<Widget> temptopics = [];

    data = widget.data;

    widget.data.forEach((key, value) {
      temptopics.add(buildTopics(key, value));
    });
    // Handle non-successful response
    setState(() {
      topics.addAll(temptopics);
    });
  }

  String urll = "";
  List<Widget> topics = [];
  Map masterTopicDict = {};
  bool ans = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Placeholder for left-alignment
            Center(child: Text(widget.title)),
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
              onToggle: (val) async {
                setState(() {
                  ans = !ans;
                });
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: topics.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: topics[index],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: sendGet,
        tooltip: 'Increment',
        child: const Icon(Icons.upload_file),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
