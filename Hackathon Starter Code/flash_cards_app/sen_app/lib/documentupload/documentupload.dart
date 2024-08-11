import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:sen_app/landing/landingpage.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  final Dio _dio = Dio();
  bool isUploading = false;
  String message = '';
  List<Widget> topics = [];

  Future<void> _pickFileAndUpload() async {
    // Pick a file
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.path != null) {
      setState(() {
        isUploading = true;
      });

      try {
        // Prepare the file
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        FormData formData = FormData.fromMap({
          'document':
              await MultipartFile.fromFile(filePath, filename: fileName),
        });

        // Send the file to the server
        Response response = await _dio.post(
          'http://192.168.0.112:5000/process_document', // Replace with your Flask server URL
          data: formData,
          options: Options(
            headers: {
              'Content-Type': 'multipart/form-data',
            },
          ),
          onSendProgress: (int sent, int total) {
            // Calculate and print the upload progress
            double progress = sent / total * 100;
            debugPrint('Upload progress: ${progress.toStringAsFixed(2)}%');
          },
        );

        // Assuming the server response is a JSON object
        final data = jsonDecode(response.data); // This should be a JSON object
        debugPrint('Server response: $data');

        setState(() {
          message = 'File uploaded successfully';
          topics.add(buildDocuments(fileName, data));
        });
      } catch (e) {
        setState(() {
          message = 'File upload failed: $e';
        });
      } finally {
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

  Widget buildDocuments(String name, dynamic data) {
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
        debugPrint("${data.runtimeType}");
        debugPrint("$name is the topic");
        debugPrint("$data is the data and datatype is ${data.runtimeType}");
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
