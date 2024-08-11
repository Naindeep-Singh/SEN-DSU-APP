import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:sen_app_latest/new_structure/student/flipcard.dart';
import 'package:sen_app_latest/new_structure/shared/questionspage.dart';

class TopicsPage extends StatefulWidget {
  const TopicsPage({super.key, required this.title, required this.data});
  final String title;
  final Map data;

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  Widget buildTopics(String name, Map data) {
    return Card(
      // color: const Color(0xFF1A1A2E), // Dark background color for cards
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade700, width: 1), // Darker grey border
      ),
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.grey[850]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0), // Match the Card's shape
        
      ), // Reduced margin for smaller appearance
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12), // Smaller padding
        leading: const Icon(
          Icons.batch_prediction,
          color: Colors.teal, // Teal color for the icon
        ),
        title: Center(
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 15, // Slightly smaller font size
              fontWeight: FontWeight.w500,
              color: Colors.white, // Light text color
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
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.teal, // Teal color for the trailing arrow icon
        ),
      ),
    )
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
        backgroundColor: Colors.black, // Changed app bar background color to black
        foregroundColor: Colors.white, // Light text color for app bar
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white, // Light text color
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          FlutterSwitch(
            activeText: "ANS",
            inactiveText: "MCQ",
            value: ans,
            activeTextColor: Colors.white, // Light text color for switch
            valueFontSize: 10.0,
            activeColor: Colors.teal, // Teal color for active switch
            inactiveTextColor: Colors.grey.shade500,
            inactiveColor: Colors.grey.shade800, // Dark grey color for inactive switch
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
        onPressed: () {},
        tooltip: 'Fetch Topics',
        backgroundColor: Colors.teal, // Teal color for the FAB
        child: const Icon(Icons.refresh, color: Colors.white), // Light icon color
      ),
      backgroundColor: const Color(0xFF000000), // Pure black background color
    );
  }
}
