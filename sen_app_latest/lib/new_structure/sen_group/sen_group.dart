import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class SenGroupPage extends StatefulWidget {
  final String? sessionTitle;
  final String? sessionCode;

  const SenGroupPage({Key? key, required this.sessionTitle, required this.sessionCode}) : super(key: key);

  @override
  _SenGroupPageState createState() => _SenGroupPageState();
}

class _SenGroupPageState extends State<SenGroupPage> {
  final List<Widget> contentList = [];
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _additionalInfoController = TextEditingController();
  bool isDarkTheme = true;
  bool isLoading = false;
  String? summaryResponse;
  bool _isBottomSheetVisible = false;

  static const apiKey = 'YOUR_API_KEY'; // Replace with your actual API key
  final model = 'gemini-1.5-pro';

  @override
  void initState() {
    super.initState();
    _loadSessionFromFirebase();
  }

  Future<void> _loadSessionFromFirebase() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .doc(widget.sessionCode)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      // Load text content
      if (data.containsKey('textContent')) {
        setState(() {
          contentList.add(Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Text(data['textContent'], style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
          ));
        });
      }
      // Load other content types here (e.g., images, PDFs)
    }
  }

  Future<void> _saveSessionToFirebase() async {
    final textContent = _textController.text;

    await FirebaseFirestore.instance.collection('sessions').doc(widget.sessionCode).set({
      'textContent': textContent,
      // Save other content types here (e.g., images, PDFs)
    });
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

      // Save the session to Firebase after adding content
      _saveSessionToFirebase();
    }
  }

  void _addImage(File imageFile, {int? insertIndex}) {
    setState(() {
      Widget imageWidget = Column(
        children: [
          Image.file(imageFile, width: 150, height: 150, fit: BoxFit.cover),
          SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, imageWidget);
      } else {
        contentList.add(imageWidget);
      }
    });
    _saveSessionToFirebase(); // Save the session after adding an image
  }

  void _addPdf(String fileName, String filePath, {int? insertIndex}) {
    setState(() {
      Widget pdfWidget = Column(
        children: [
          ListTile(
            leading: Icon(Icons.picture_as_pdf, color: isDarkTheme ? Colors.teal : Colors.black),
            title: Text(fileName, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
            subtitle: Text('PDF Document', style: TextStyle(color: isDarkTheme ? Colors.grey : Colors.black54)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(filePath: filePath),
                ),
              );
            },
          ),
          SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, pdfWidget);
      } else {
        contentList.add(pdfWidget);
      }
    });
    _saveSessionToFirebase(); // Save the session after adding a PDF
  }

  void _addFile(String fileName, String filePath, {int? insertIndex}) {
    setState(() {
      Widget fileWidget = Column(
        children: [
          ListTile(
            leading: Icon(Icons.insert_drive_file, color: isDarkTheme ? Colors.teal : Colors.black),
            title: Text(fileName, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
            subtitle: Text('File', style: TextStyle(color: isDarkTheme ? Colors.grey : Colors.black54)),
            onTap: () {
              // Handle file open
            },
          ),
          SizedBox(height: 10),
        ],
      );
      if (insertIndex != null) {
        contentList.insert(insertIndex, fileWidget);
      } else {
        contentList.add(fileWidget);
      }
    });
    _saveSessionToFirebase(); // Save the session after adding a file
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

    // Extract text and image content from the session
    for (var widget in contentList) {
      if (widget is Padding && widget.child is Text) {
        sessionText.add((widget.child as Text).data ?? '');
      } else if (widget is Column) {
        for (var child in widget.children) {
          if (child is Image) {
            final File imageFile = (child.image as FileImage).file;
            final String base64Image = base64Encode(imageFile.readAsBytesSync());
            sessionImages.add(base64Image);
          }
        }
      }
    }

    String content = sessionText.join("\n");
    content += "\nAdditional Info: ${_additionalInfoController.text}";

    _showSummaryBar(content, sessionImages);

    try {
      summaryResponse = await _getSummaryFromGemini(content, sessionImages);
    } catch (e) {
      summaryResponse = "Failed to generate summary.";
    } finally {
      setState(() {
        isLoading = false;
      });

      _showSummaryPanel();
    }
  }

  Future<String> _getSummaryFromGemini(String content, List<String> images) async {
    final url = Uri.parse('https://api.your-service.com/generate-summary'); // Update with actual Gemini API URL
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': model,
        'input': {
          'text': content,
          'images': images,
        },
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['summary'];
    } else {
      throw Exception('Failed to load summary');
    }
  }

  void _showSummaryBar(String content, List<String> images) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Sending content for summarization...'),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Row(
            children: [
              Text('Session Summary', style: TextStyle(color: isDarkTheme ? Colors.teal : Colors.black)),
              Lottie.network(
                'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                height: 40,
                width: 40,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(summaryResponse ?? '', style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close', style: TextStyle(color: Colors.teal)),
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
        titleMedium: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildThemeData(),
      home: Scaffold(
        appBar: AppBar(
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
                            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText: "Write something, or press '+' for commands...",
                              hintStyle: TextStyle(color: isDarkTheme ? Colors.grey : Colors.black54),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (text) {
                              setState(() {
                                contentList.add(
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Text(text, style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black)),
                                  ),
                                );
                                _textController.clear();
                                _saveSessionToFirebase(); // Save the session after adding text
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
                    children: [
                      IconButton(
                        icon: Icon(Icons.add, color: isDarkTheme ? Colors.teal : Colors.black),
                        onPressed: () => _uploadFile(),
                      ),
                      Text(
                        'Upload Image, PDF, Document...',
                        style: TextStyle(color: isDarkTheme ? Colors.grey : Colors.black54),
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
                      padding: EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: _additionalInfoController,
                            style: TextStyle(color: isDarkTheme ? Colors.white : Colors.black),
                            decoration: InputDecoration(
                              hintText: "Add additional information before generating the summary...",
                              hintStyle: TextStyle(color: isDarkTheme ? Colors.grey : Colors.black54),
                              border: InputBorder.none,
                            ),
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: _summarizeSession,
                                child: Text('Generate Summary'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                              ),
                              ElevatedButton(
                                onPressed: _toggleBottomSheet,
                                child: Text('Cancel'),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _toggleBottomSheet,
          backgroundColor: Colors.teal,
          child: Icon(_isBottomSheetVisible ? Icons.close : Icons.summarize, color: Colors.white),
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
        title: Text('PDF Viewer'),
      ),
      body: SfPdfViewer.file(File(filePath)), // Proper PDF Viewer implementation
    );
  }
}
