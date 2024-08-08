import 'dart:developer';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sen_app_latest/landing/landingpage.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:json5/json5.dart' as json5;
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Documentupload extends StatefulWidget {
  const Documentupload({super.key, required this.username});
  final String username;

  @override
  State<Documentupload> createState() => _StudentPageState();
}

class _StudentPageState extends State<Documentupload> {
  bool isUploading = false;
  String message = '';
  List<Widget> topics = [];

  Future<void> _pickFileAndUpload() async {
    // Pick a file
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

        //test if we get correcly formatted string
        var test = json5.json5Decode(geminiResponse);
        log('ITS FORMATTED!');
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
          tempTopics.add(buildDocuments(
              data['documentname'], json5.json5Decode(data['documenttext'])));
        }
        setState(() {
          topics.addAll(tempTopics);
        });
      } catch (e) {
        log('$e');
        snackbarMsg(
            "File Upload Failed!", const Color.fromRGBO(240, 13, 13, 0.61));
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
    // Remove any unwanted characters or control characters
    String cleanedText = text
        .replaceAll(RegExp(r'\s+'),
            ' ') // Replace multiple whitespace with a single space
        .replaceAll(RegExp(r'[^\x20-\x7E]'),
            '') // Remove non-printable ASCII characters
        .trim(); // Remove leading and trailing whitespace

    // Escape JSON special characters
    cleanedText = cleanedText.replaceAll('"', r'\"'); // Escape double quotes
    cleanedText = cleanedText.replaceAll('\\', r'\\'); // Escape backslashes

    return cleanedText;
  }

  Future<String> _sendFileToGemini(String extractedtext) async {
    // Define the mime type for PDF
    log('Entered send filet to gemini');
    const apiKey = 'AIzaSyCOmrBF7Y2qrT8cZUkgNGt2JGZ_CmyLqHc';
    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    final model = GenerativeModel(
        model: 'gemini-1.5-pro',
        apiKey: apiKey,
        generationConfig:
            GenerationConfig(responseMimeType: "application/json"));
    // Create the content to send to Gemini
    final content = [
      Content.text(
          'Give me the response in well-formatted JSON format with these Instructions: Read the provided article carefully and identify the main topics discussed. Article:{$extractedtext} Questions: For each identified topic, generate 3 multiple-choice questions with only easy and hard difficulty levels. You should have a maximum of 4 topics. Structure the output in the following JSON format: {"topicname": {"questionNumber": {"question": "question here", "difficultyLevel": "difficulty", "answer": "answer here", "options": ["4 options here"]}}} Important: To avoid JSON syntax errors, ensure that all keys and string values are enclosed in double quotes. Avoid using single quotes or unescaped special characters within strings. Examples: Good: {"Neural Networks": {"1": {"question": "What is a neural network inspired by?", "difficultyLevel": "easy", "answer": "Biological neural networks", "options": ["Biological neural networks", "Mechanical systems", "Quantum computing", "Traditional algorithms"]}, "2": {"question": "Which learning method involves the network adjusting weights based on errors?", "difficultyLevel": "hard", "answer": "Supervised learning", "options": ["Unsupervised learning", "Reinforcement learning", "Supervised learning", "Semi-supervised learning"]}}}')
    ];
    final response = await model.generateContent(content);
    log("${response.text}");
    return "${response.text}";
  }

  Widget buildDocuments(String name, dynamic data) {
    topics = [];
    return ListTile(
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
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Lander(
              data: data,
            ),
          ),
        );
      },
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Colors.black, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(25)),
      ),
      trailing: GestureDetector(
        child: Icon(
          Icons.arrow_forward,
          color: Colors.red.shade600,
        ),
        onTap: () {
          debugPrint("arrow forward tapped");
        },
      ),
    );
  }

  Widget buildProgressIndicator() {
    return PopScope(
      // Prevent dismissing the dialog by tapping outside
      child: Dialog(
        backgroundColor: Colors.black.withOpacity(0.5),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Uploading...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }

  void snackbarMsg(String errorMessage, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: color,
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      content: Center(
        child: Text(
          errorMessage,
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.w500, fontSize: 15),
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
    List<DocumentSnapshot> docs = querySnapshot.docs;
    message = 'File processed and sent to Gemini successfully';
    for (var doc in docs) {
      var data = doc.data() as Map<String, dynamic>;
      tempTopics.add(buildDocuments(
          data['documentname'], json5.json5Decode(data['documenttext'])));
    }
    setState(() {
      topics.addAll(tempTopics);
    });
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text("Document Upload")),
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
        onPressed: _pickFileAndUpload,
        tooltip: 'Upload',
        child: const Icon(Icons.upload_file),
      ),
    );
  }
}
