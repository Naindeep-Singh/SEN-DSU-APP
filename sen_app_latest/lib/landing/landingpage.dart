import 'package:flutter/material.dart';
import 'package:sen_app_latest/main.dart';

class Lander extends StatefulWidget {
  final Map data;

  const Lander({super.key, required this.data});

  @override
  State<Lander> createState() => _LanderState();
}

class _LanderState extends State<Lander> {
  @override
  void initState() {
    super.initState();
    // Directly navigate to the Student login page without showing the Lander screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MyHomePage(
            title: "Student",
            data: widget.data,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // This build method will never be called because we're directly navigating to the Student login page
    return Container(
      color: Colors.black, // Set a background color in case the build method is ever called
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;
  final Map data;

  const WebViewScreen({super.key, required this.url, required this.data});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'PDF - AI',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange, // Updated to match the document upload style
        centerTitle: true,
        elevation: 0, // Smooth, flat look for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: Colors.orange,
                size: 100,
              ),
              const SizedBox(height: 20),
              Text(
                'Redirecting to ${widget.url}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Data: ${widget.data}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
