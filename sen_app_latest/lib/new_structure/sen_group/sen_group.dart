import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SenGroupPage extends StatefulWidget {
  final String? sessionTitle;
  final String? sessionCode;
  final String username;

  const SenGroupPage(
      {super.key,
      required this.sessionTitle,
      required this.sessionCode,
      required this.username});

  @override
  SenGroupPageState createState() => SenGroupPageState();
}

class SenGroupPageState extends State<SenGroupPage> {
  final List<Widget> contentList = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _additionalInfoController =
      TextEditingController();
  bool isDarkTheme = true;
  bool isLoading = false;
  String? summaryResponse;
  bool _isBottomSheetVisible = false;

  Offset floatingButtonOffset =
      const Offset(20, 100); // Initialize with default position

  static const apiKey = 'AIzaSyCvxSwUiZdFR7PcSDzabYfpqKKLmHkOSuY';
  final model = 'gemini-1.5-pro';

  @override
  void initState() {
    super.initState();
    _loadSessionFromFirebase();
  }

  Future<void> _saveTextToFirebase(String text, String username) async {
    final sessionRef = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .collection('textEntries');

    await sessionRef.add({
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'username': username,
    });

    // Display the save notification only in SenGroupPage
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          const Text('Text saved successfully!', textAlign: TextAlign.center),
      backgroundColor: Colors.teal,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 0.0),
    ));
  }

  // Function to extract all text from the session
  String getAllSessionText() {
    List<String> sessionText = [];

    for (var widget in contentList) {
      if (widget is Padding && widget.child is Text) {
        sessionText.add((widget.child as Text).data ?? '');
      }
    }

    return sessionText.join("\n");
  }

  Future<String> getSummary(
      String extractedText, String additionalNotes) async {
    log('getting summary from Gemini');
    const apiKey = 'AIzaSyCOmrBF7Y2qrT8cZUkgNGt2JGZ_CmyLqHc';
    final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
            responseMimeType: "text/plain")); // Request plain text

    final content = [
      Content.text('''
    {
     "instructions": [
            "Carefully read the provided session text, images, and PDFs.",
            "Generate a concise summary of the entire session content, including any relevant information from the images and PDFs.",
            "If any questions were asked during the session, particularly related to topics such as addiction or any other mentioned topics, provide appropriate responses or answers to those questions.",
            "If no session or questions were explicitly mentioned, generate responses based on the provided additional information or general context.",
            "Output the summary and any relevant answers as a simple string, without JSON formatting."
          ],
          "text": "$extractedText",
          "additionalNotes": "$additionalNotes",
          "questions": "If there are any questions asked in the session, provide answers or guidance for those as well."
        }
        ''')
    ];

    final response = await model.generateContent(content);
    log("${response.text}");
    return "${response.text}";
  }

  Future<void> _loadSessionFromFirebase() async {
    final sessionRef = FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .collection('textEntries');

    final snapshot = await sessionRef.orderBy('timestamp').get();

    setState(() {
      contentList.clear();
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final text = data['text'] ?? '';
        final username = data['username'] ?? 'Anonymous';
        final timestamp = data['timestamp']?.toDate() ?? DateTime.now();

        contentList.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            '$text\n- $username, ${timestamp.toLocal()}',
            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
          ),
        ));
      }
    });
  }

  Future<void> _saveSessionToFirebase() async {
    final textContent = _textController.text;

    await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .set({
      'textContent': textContent,
    });

    // Display the save notification only in SenGroupPage
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Session saved successfully!',
          textAlign: TextAlign.center),
      backgroundColor: Colors.teal,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.only(top: 0.0),
    ));
  }

  void _uploadFile({int? insertIndex}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result != null && result.files.single.path != null) {
      String fileName = result.files.single.name;
      String filePath = result.files.single.path!;
      String fileExtension = result.files.single.extension!.toLowerCase();

      if (['png', 'jpg', 'jpeg', 'gif'].contains(fileExtension)) {
        _addImage(File(filePath), insertIndex: insertIndex);
      } else if (fileExtension == 'pdf') {
        _addPdf(fileName, filePath, insertIndex: insertIndex);
      } else {
        _addFile(fileName, filePath, insertIndex: insertIndex);
      }

      _saveSessionToFirebase();
    }
  }

  void _addImage(File imageFile, {int? insertIndex}) {
    setState(() {
      Widget imageWidget = Column(
        children: [
          Image.file(imageFile, width: 150, height: 150, fit: BoxFit.cover),
          const SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, imageWidget);
      } else {
        contentList.add(imageWidget);
      }
    });
    _saveSessionToFirebase();
  }

  void _addPdf(String fileName, String filePath, {int? insertIndex}) {
    setState(() {
      Widget pdfWidget = Column(
        children: [
          ListTile(
            leading: Icon(Icons.picture_as_pdf,
                color: isDarkTheme ? Colors.teal : Colors.black),
            title: Text(fileName,
                style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black)),
            subtitle: Text('PDF Document',
                style: TextStyle(
                    color: isDarkTheme ? Colors.grey : Colors.black54)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(filePath: filePath),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, pdfWidget);
      } else {
        contentList.add(pdfWidget);
      }
    });
    _saveSessionToFirebase();
  }

  void _addFile(String fileName, String filePath, {int? insertIndex}) {
    setState(() {
      Widget fileWidget = Column(
        children: [
          ListTile(
            leading: Icon(Icons.insert_drive_file,
                color: isDarkTheme ? Colors.teal : Colors.black),
            title: Text(fileName,
                style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black)),
            subtitle: Text('File',
                style: TextStyle(
                    color: isDarkTheme ? Colors.grey : Colors.black54)),
            onTap: () {
              // Handle file open
            },
          ),
          const SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, fileWidget);
      } else {
        contentList.add(fileWidget);
      }
    });
    _saveSessionToFirebase();
  }

  void _toggleTheme() {
    setState(() {
      isDarkTheme = !isDarkTheme;
    });
  }

  void _toggleBottomSheet() {
    setState(() {
      _isBottomSheetVisible = !_isBottomSheetVisible;
    });
  }

  Future<void> _summarizeSession() async {
    setState(() {
      isLoading = true;
    });

    List<String> sessionText = [];
    List<String> sessionImages = [];

    for (var widget in contentList) {
      if (widget is Padding && widget.child is Text) {
        sessionText.add((widget.child as Text).data ?? '');
      } else if (widget is Column) {
        for (var child in widget.children) {
          if (child is Image) {
            final File imageFile = (child.image as FileImage).file;
            final String base64Image =
                base64Encode(imageFile.readAsBytesSync());
            sessionImages.add(base64Image);
          }
        }
      }
    }

    String content = sessionText.join("\n");
    content += "\nAdditional Info: ${_additionalInfoController.text}";

    _showSummaryBar(content, sessionImages);

    try {
      await _saveSessionToFirebase(); // Save session before summarizing
      summaryResponse = await getSummary(getAllSessionText(), content);
      await _saveTextToFirebase('$summaryResponse', 'Gemini');
      await _loadSessionFromFirebase();
      debugPrint(summaryResponse);
    } catch (e) {
      summaryResponse = "Failed to generate summary.";
    } finally {
      setState(() {
        isLoading = false;
      });

      _showSummaryPanel();
    }
  }

  void _showSummaryBar(String content, List<String> images) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Sending content for summarization...'),
          Text('Text: $content'),
          Text('Images: ${images.length} image(s)'),
        ],
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  void _showSummaryPanel() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkTheme ? Colors.grey[850] : Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Text('Session Summary',
                  style: TextStyle(
                      color: isDarkTheme ? Colors.teal : Colors.black)),
              Lottie.network(
                'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                height: 40,
                width: 40,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(summaryResponse ?? '',
                style: TextStyle(
                    color: isDarkTheme ? Colors.white : Colors.black)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close',
                  style: const TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  ThemeData _buildThemeData() {
    return ThemeData(
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      primaryColor: Colors.teal,
      scaffoldBackgroundColor: isDarkTheme ? Colors.black : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: isDarkTheme ? Colors.black : Colors.teal,
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
        titleMedium:
            TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      ),
    );
  }

  String globalText = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(),
      home: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back)),
          title: Text(widget.sessionTitle ?? 'Session Group'),
          actions: [
            IconButton(
              icon: Icon(isDarkTheme ? Icons.wb_sunny : Icons.nights_stay),
              onPressed: _toggleTheme,
            ),
          ],
        ),
        body: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: contentList.length + 1,
                      itemBuilder: (context, index) {
                        if (index == contentList.length) {
                          return TextField(
                            controller: _textController,
                            maxLines: null,
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText:
                                  "Write something, or press '+' for commands...",
                              hintStyle: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.grey
                                      : Colors.black54),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (text) {
                              setState(() {
                                globalText = text;
                                contentList.add(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10.0),
                                    child: Text(text,
                                        style: TextStyle(
                                            color: isDarkTheme
                                                ? Colors.white
                                                : Colors.black)),
                                  ),
                                );
                                _textController.clear();
                                _saveTextToFirebase(text, widget.username);
                              });
                            },
                          );
                        } else {
                          return GestureDetector(
                            onLongPress: () {
                              _uploadFile(insertIndex: index);
                            },
                            child: contentList[index],
                          );
                        }
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Place buttons on opposite sides
                    children: [
                      IconButton(
                        icon: Icon(Icons.add,
                            color: isDarkTheme ? Colors.teal : Colors.black),
                        onPressed: () => _uploadFile(),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _saveTextToFirebase(
                              globalText, widget.username);
                          await _loadSessionFromFirebase();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (isLoading)
              Center(
                child: Lottie.network(
                  'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                  height: 100,
                  width: 100,
                ),
              ),
            _isBottomSheetVisible
                ? Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      color: isDarkTheme ? Colors.grey[900] : Colors.white,
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _additionalInfoController,
                            style: TextStyle(
                                color:
                                    isDarkTheme ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText:
                                  "Add additional information before generating the summary...",
                              hintStyle: TextStyle(
                                  color: isDarkTheme
                                      ? Colors.grey
                                      : Colors.black54),
                              border: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _summarizeSession,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal),
                                child: const Text('Generate Summary'),
                              ),
                              ElevatedButton(
                                onPressed: _toggleBottomSheet,
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              left: floatingButtonOffset.dx,
              top: floatingButtonOffset.dy,
              child: GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    floatingButtonOffset += details.delta;
                  });
                },
                child: FloatingActionButton(
                  onPressed: _toggleBottomSheet,
                  backgroundColor: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(255, 199, 205, 204)
                          .withOpacity(0.8), // Slightly transparent background
                    ),
                    padding: const EdgeInsets.all(
                        8), // Padding inside the round button
                    child: Lottie.network(
                      'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                      height: 40,
                      width: 40,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back)),
        title: const Text('PDF Viewer'),
      ),
      body: SfPdfViewer.file(File(filePath)),
    );
  }
}
