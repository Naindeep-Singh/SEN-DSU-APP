import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

import 'package:flutter/services.dart';

class ClassFormDialog extends StatefulWidget {
  const ClassFormDialog({super.key, required this.username});
  final String username;

  @override
  ClassFormDialogState createState() => ClassFormDialogState();
}

class ClassFormDialogState extends State<ClassFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String generatedCode = "";

  String _generateRandomCode(int length) {
    const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      // Generate a random code
      setState(() {
        generatedCode = _generateRandomCode(10);
      });

      // Send data to Firestore
      await FirebaseFirestore.instance.collection('classes').add({
        'classname': _classNameController.text,
        'description': _descriptionController.text,
        'code': generatedCode,
        'timestamp': FieldValue.serverTimestamp(),
        'teacher': widget.username
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Class'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _classNameController,
              decoration: const InputDecoration(labelText: 'Class Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a class name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Generated Code: $generatedCode',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: generatedCode));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Code copied to clipboard!'),
                    ));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await _submitData();
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
