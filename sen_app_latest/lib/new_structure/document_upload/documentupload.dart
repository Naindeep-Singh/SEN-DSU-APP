import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:json5/json5.dart' as json5;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sen_app_latest/landing/landingpage.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:lottie/lottie.dart';

class DocumentUpload extends StatefulWidget {
  final String username;

  const DocumentUpload({super.key, required this.username});

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  bool isUploading = false;
  String message = '';
  List<Widget> topics = [];

  Future<void> _pickFileAndUpload() async {
    List<Widget> tempTopics = [];

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        isUploading = true;
      });

      // Show the progress indicator dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return buildProgressIndicator();
          },
        );
      }
      try {
        // Prepare the file
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        File file = File(filePath);
        final PdfDocument document =
            PdfDocument(inputBytes: file.readAsBytesSync());
        String extractedText = PdfTextExtractor(document).extractText();
        String processedText = preprocessText(extractedText);
        document.dispose();
        log(processedText);

        String geminiResponse = await _sendFileToGemini(processedText);

        // Test if we get correctly formatted string
        var test = json5.json5Decode(geminiResponse);
        log('JSON is formatted correctly.');
        snackbarMsg("File Uploaded Successfully!", Colors.teal);

        await FirebaseFirestore.instance.collection('documents').add({
          'documenttext': geminiResponse,
          'documentname': fileName,
          'timestamp': FieldValue.serverTimestamp(),
          'username': widget.username,
        });

        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('documents')
            .where('username', isEqualTo: widget.username)
            .get();
        List<DocumentSnapshot> docs = querySnapshot.docs;

        message = 'File processed and sent to Gemini successfully';
        for (var doc in docs) {
          var data = doc.data() as Map<String, dynamic>;
          tempTopics.add(buildDocuments(data['documentname'],
              json5.json5Decode(data['documenttext']), doc.id));
        }
        setState(() {
          topics.addAll(tempTopics);
        });
      } catch (e) {
        log('Error during upload: $e');
        snackbarMsg("File Upload Failed: $e", Colors.red);
        setState(() {
          message = 'File upload failed: $e';
        });
      } finally {
        if (mounted) {
          Navigator.pop(context);
        }
        setState(() {
          isUploading = false;
        });
      }
    } else {
      setState(() {
        message = 'No file selected';
      });
    }
  }

  String preprocessText(String text) {
    String cleanedText = text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\x20-\x7E]'), '')
        .trim();

    cleanedText = cleanedText.replaceAll('"', r'\"');
    cleanedText = cleanedText.replaceAll('\\', r'\\');

    return cleanedText;
  }

  Future<String> _sendFileToGemini(String extractedtext) async {
    log('Sending file to Gemini');
    const apiKey = 'AIzaSyCOmrBF7Y2qrT8cZUkgNGt2JGZ_CmyLqHc';
    final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig:
            GenerationConfig(responseMimeType: "application/json"));
    final content = [
      Content.text('''
      {
        "instructions": [
          "Here is an article. Please read it carefully and then answer the following questions: ",
          "1. Identify the main topics discussed in the article."
        ],
        "text": "$extractedtext",
        "desired_output": [
          "For each identified topic, generate 3 multiple-choice questions with only easy and hard difficulty levels.",
          "You should have a maximum of 4 topics.",
          "Structure the output in the following JSON format:",
          "{topicname: {questionNumber: {question: 'question here', difficultyLevel: 'difficulty', answer: 'answer here', options: ['4 options here']}}}"
        ],
        "examples": {
          "good": [
            {
              "Neural Networks": {
                "1": {
                  "question": "What is a neural network inspired by?",
                  "difficultyLevel": "easy",
                  "answer": "Biological neural networks",
                  "options": [
                    "Biological neural networks",
                    "Mechanical systems",
                    "Quantum computing",
                    "Traditional algorithms"
                  ]
                },
                "2": {
                  "question": "Which learning method involves the network adjusting weights based on errors?",
                  "difficultyLevel": "hard",
                  "answer": "Supervised learning",
                  "options": [
                    "Unsupervised learning",
                    "Reinforcement learning",
                    "Supervised learning",
                    "Semi-supervised learning"
                  ]
                },
                "3": {
                  "question": "What is a key feature of recurrent neural networks?",
                  "difficultyLevel": "easy",
                  "answer": "Information flows in a loop",
                  "options": [
                    "Information flows in a loop",
                    "Information flows in one direction",
                    "They are used for image recognition",
                    "They have a fixed number of layers"
                  ]
                }
              }
            }
          ],
          "bad": [
            {
              "Neural Networks": {
                "question1": {
                  "question": "What is the color of the sky?",
                  "difficultyLevel": "easy",
                  "answer": "Blue",
                  "options": ["Blue", "Green", "Red", "Yellow"]
                }
              }
            }
          ]
        }
      }
      ''')
    ];

    final response = await model.generateContent(content);
    log("${response.text}");
    return "${response.text}";
  }

  Widget buildDocuments(String name, dynamic data, String docId) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const Icon(
          Icons.picture_as_pdf,
          color: Colors.redAccent,
          size: 36,
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete_forever, color: Colors.red, size: 28),
              onPressed: () => _deleteDocument(docId),
              tooltip: "Delete Document",
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade600,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Lander(
                data: data,
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _deleteDocument(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('documents')
          .doc(docId)
          .delete();
      snackbarMsg("Document deleted successfully!", Colors.teal);
      setState(() {
        topics.removeWhere((widget) =>
            (widget as Card).key == ValueKey(docId)); // Update the UI
      });
    } catch (e) {
      log('Failed to delete document: $e');
      snackbarMsg("Failed to delete document!", Colors.red);
    }
  }

  Widget buildProgressIndicator() {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Padding(
          padding: EdgeInsets.all(16), // Reduce padding to make it smaller
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16), // Reduce space between elements
              Text('Uploading...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  void snackbarMsg(String errorMessage, Color color) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar(); // Prevent duplication
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w500, fontSize: 16),
        ),
      ),
    ));
  }

  Future<void> getDocs() async {
    List<Widget> tempTopics = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('documents')
        .where('username', isEqualTo: widget.username)
        .get();
    message = 'File processed and sent to Gemini successfully';
    try {
      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        tempTopics.add(buildDocuments(data['documentname'],
            json5.json5Decode(data['documenttext']), doc.id));
      }
      setState(() {
        topics.addAll(tempTopics);
      });
    } catch (e) {
      log('$e');
    }
  }

  @override
  void initState() {
    super.initState();
    getDocs();
  }

  @override
  void dispose() {
    super.dispose();
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: topics.length,
                  itemBuilder: (BuildContext context, int index) {
                    return topics[index];
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0), // Reduced padding
                child: FloatingActionButton.extended(
                  onPressed: _pickFileAndUpload,
                  label: const Text('Upload Document'),
                  icon: const Icon(Icons.upload_file),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Slightly reduced radius
                  ),
                ),
              ),
            ],
          ),
          if (isUploading)
            Center(
              child: Lottie.network(
                'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
                height: 80, // Adjusted size to be slightly smaller
                width: 80,
              ),
            ),
        ],
      ),
    );
  }
}
