import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'dart:io';
import 'dart:developer' as dev;

import 'package:syncfusion_flutter_pdf/pdf.dart';

class VivaDialog extends StatefulWidget {
  final String username;
  final Map classData;

  const VivaDialog({super.key, required this.username, required this.classData});

  @override
  VivaDialogState createState() => VivaDialogState();
}

class VivaDialogState extends State<VivaDialog> {
  String? title;
  DateTime? startDate;
  DateTime? endDate;
  bool isUploading = false;
  bool fileUploaded = false;
  String message = '';

  Future<void> storeVivaDetails({
    required String? vivaName,
    required DateTime? start,
    required DateTime? end,
    required String vivatext,
    required String teacherUsername,
    required String className,
    required String code,
  }) async {
    try {
      // Add the viva details to the 'viva' collection
      DocumentReference vivaRef =
          await FirebaseFirestore.instance.collection('viva').add({
        'vivaname': vivaName ?? '',
        'start': start ?? FieldValue.serverTimestamp(),
        'end': end ?? FieldValue.serverTimestamp(),
        'created': FieldValue.serverTimestamp(),
        'vivatext': vivatext,
        'teacher': teacherUsername,
        'class': className,
        'code': code
      });

      // Fetch the document ID of the newly created viva
      String vivaDocId = vivaRef.id;

      // Update the 'classes' document to include the new viva ID
      QuerySnapshot classSnapshot = await FirebaseFirestore.instance
          .collection('classes')
          .where('code', isEqualTo: code)
          .get();

      if (classSnapshot.docs.isNotEmpty) {
        DocumentReference classRef = classSnapshot.docs.first.reference;

        // Add the new viva document ID to the 'viva' field of the class document
        await classRef.update({
          'viva': FieldValue.arrayUnion([vivaDocId]),
        });

        dev.log('Viva details stored and class updated successfully');
      } else {
        dev.log('Class not found with code: $code');
      }
    } catch (e) {
      dev.log('Failed to store Viva details: $e');
    }
  }

  void _pickFileAndUpload() async {
    setState(() {
      isUploading = true;
      fileUploaded = false;
      message = 'Uploading file...';
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      // Show the progress indicator dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return buildProgressIndicator();
        },
      );

      try {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        File file = File(filePath);
        final PdfDocument document =
            PdfDocument(inputBytes: file.readAsBytesSync());
        String extractedText = PdfTextExtractor(document).extractText();
        String processedText = preprocessText(extractedText);
        document.dispose();
        dev.log(processedText);

        String geminiResponse = await _sendFileToGemini(processedText);
        await FirebaseFirestore.instance.collection('documents').add({
          'documenttext': geminiResponse,
          'documentname': fileName,
          'timestamp': FieldValue.serverTimestamp(),
          'username': widget.username,
        });

        await storeVivaDetails(
            vivaName: title,
            start: startDate,
            end: endDate,
            vivatext: geminiResponse,
            teacherUsername: widget.username,
            className: widget.classData['classname'] ?? '',
            code: widget.classData['code'] ?? '');

        setState(() {
          fileUploaded = true;
          message = 'File uploaded successfully';
        });
      } catch (e) {
        dev.log('$e');
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
        isUploading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchVivaDetails(
      String teacherUsername) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('vivas')
          .where('teacher', isEqualTo: teacherUsername)
          .get();

      List<Map<String, dynamic>> vivaDetails = querySnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;

        // Safely handle the timestamp fields
        DateTime? start = data['start'] != null
            ? (data['start'] as Timestamp).toDate()
            : null;
        DateTime? end = data['end'] != null ? (data['end'] as Timestamp).toDate() : null;

        return {
          ...data,
          'start': start,
          'end': end,
        };
      }).toList();

      return vivaDetails;
    } catch (e) {
      dev.log('Failed to fetch Viva details: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Viva"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: const InputDecoration(labelText: "Title"),
            onChanged: (value) {
              title = value;
            },
          ),
          TextField(
            decoration: const InputDecoration(labelText: "Start Date"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                );
                if (pickedTime != null) {
                  setState(() {
                    startDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
            controller: TextEditingController(
              text: startDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(startDate!)
                  : '',
            ),
          ),
          TextField(
            decoration: const InputDecoration(labelText: "End Date"),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(DateTime.now()),
                );
                if (pickedTime != null) {
                  setState(() {
                    endDate = DateTime(
                      pickedDate.year,
                      pickedDate.month,
                      pickedDate.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );
                  });
                }
              }
            },
            controller: TextEditingController(
              text: endDate != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(endDate!)
                  : '',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: isUploading ? null : _pickFileAndUpload,
            child: Text(fileUploaded ? "File Uploaded" : "Upload File"),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: fileUploaded ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: fileUploaded
              ? () {
                  if (title != null && startDate != null && endDate != null) {
                    setState(() {}); // Only to update local state in the dialog
                    Navigator.of(context).pop({
                      'title': title,
                      'start': startDate,
                      'end': endDate,
                    });
                  }
                }
              : null,
          child: const Text("Add"),
        ),
      ],
    );
  }

  Widget buildProgressIndicator() {
    return Center(
      child: Lottie.network(
        'https://lottie.host/bf54bc22-5ef0-44db-872f-6c859e16384d/OXWwJtv9g5.json',
        width: 150,
        height: 150,
      ),
    );
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
    dev.log('Entered send file to gemini');
    const apiKey = 'AIzaSyCOmrBF7Y2qrT8cZUkgNGt2JGZ_CmyLqHc'; // Replace with your Google API Key
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
            },
            {
              "Evolution and Biological Inspiration": {
                "1": {
                  "question": "What inspired the development of neural networks?",
                  "difficultyLevel": "easy",
                  "answer": "The brain's ability to solve complex problems",
                  "options": [
                    "The brain's ability to solve complex problems",
                    "Advancements in traditional computing",
                    "Development of new programming languages",
                    "Increased data storage capabilities"
                  ]
                },
                "2": {
                  "question": "When did significant advances in neural networks occur?",
                  "difficultyLevel": "hard",
                  "answer": "Late 1980s",
                  "options": [
                    "Early 1940s",
                    "Late 1980s",
                    "Early 2000s",
                    "Late 1990s"
                  ]
                },
                "3": {
                  "question": "What function do synapses serve in a neuron?",
                  "difficultyLevel": "easy",
                  "answer": "Connect axons to dendrites",
                  "options": [
                    "Connect axons to dendrites",
                    "Process information",
                    "Transmit electrical signals",
                    "Store memories"
                  ]
                }
              }
            },
            {
              "Training Methods": {
                "1": {
                  "question": "Which learning method involves the network self-organizing based on input features?",
                  "difficultyLevel": "hard",
                  "answer": "Unsupervised learning",
                  "options": [
                    "Supervised learning",
                    "Unsupervised learning",
                    "Reinforcement learning",
                    "Semi-supervised learning"
                  ]
                },
                "2": {
                  "question": "What is the primary goal of supervised learning?",
                  "difficultyLevel": "easy",
                  "answer": "Adjust weights based on errors",
                  "options": [
                    "Adjust weights based on errors",
                    "Self-organize based on input features",
                    "Maximize reward signals",
                    "Minimize training time"
                  ]
                },
                "3": {
                  "question": "What type of neural network is suitable for time-series forecasting?",
                  "difficultyLevel": "hard",
                  "answer": "Recurrent neural networks",
                  "options": [
                    "Feedforward neural networks",
                    "Recurrent neural networks",
                    "Auto-associative neural networks",
                    "Convolutional neural networks"
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
                },
                "question2": {
                  "question": "How many continents are there?",
                  "difficultyLevel": "hard",
                  "answer": "Seven",
                  "options": ["Five", "Six", "Seven", "Eight"]
                },
                "3": {
                  "question": "Which is the largest ocean?",
                  "difficultyLevel": "easy",
                  "answer": "Pacific Ocean",
                  "options": [
                    "Atlantic Ocean",
                    "Indian Ocean",
                    "Arctic Ocean",
                    "Pacific Ocean"
                  ]
                }
              }
            },
            {
              "Neural Networks": {
                "1": {
                  "question": "What is it?",
                  "difficultyLevel": "easy",
                  "answer": "",
                  "options": ["", "", "", ""]
                },
                "2": {
                  "question": "Explain the concept.",
                  "difficultyLevel": "hard",
                  "answer": "",
                  "options": ["", "", "", ""]
                },
                "3": {
                  "question": "What do you think?",
                  "difficultyLevel": "easy",
                  "answer": "",
                  "options": ["", "", "", ""]
                }
              }
            }
          ]
        }
      }
      ''')
    ];

    final response = await model.generateContent(content);
    dev.log("${response.text}");
    return "${response.text}";
  }

  Widget buildDocuments(String name, Map<String, dynamic> data) {
    return ListTile(
      title: Text(name),
      subtitle: Text(data.toString()),
    );
  }
}
