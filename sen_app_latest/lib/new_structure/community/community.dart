import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';

class CommunityPage extends StatefulWidget {
  final String username;

  const CommunityPage({Key? key, required this.username}) : super(key: key);

  @override
  _CommunityPageState createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _questionController = TextEditingController();
  List<Map<String, dynamic>> questions = [];
  List<Map<String, dynamic>> filteredQuestions = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterQuestions);
    _fetchQuestions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CommunityQuestions')
        .get();
    List<Map<String, dynamic>> tempQuestions = querySnapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList();

    setState(() {
      questions = tempQuestions;
      filteredQuestions = tempQuestions;
    });
  }

  void _filterQuestions() {
    setState(() {
      filteredQuestions = questions
          .where((question) => question['question'] != null && question['question']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  Future<void> _addQuestion() async {
    if (_questionController.text.isNotEmpty) {
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('CommunityQuestions')
          .add({
        'askedBy': widget.username,
        'question': _questionController.text,
        'answers': [],
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        questions.add({
          'askedBy': widget.username,
          'question': _questionController.text,
          'answers': [],
          'id': docRef.id,
        });
        filteredQuestions = questions;
        _questionController.clear();
      });
    }
  }

  Future<void> _deleteQuestion(String id) async {
    await FirebaseFirestore.instance
        .collection('CommunityQuestions')
        .doc(id)
        .delete();

    setState(() {
      questions.removeWhere((question) => question['id'] == id);
      filteredQuestions = questions;
    });
  }

  void _answerQuestion(String id, String answer) async {
    if (answer.isNotEmpty) {
      DocumentReference docRef =
          FirebaseFirestore.instance.collection('CommunityQuestions').doc(id);

      await docRef.update({
        'answers': FieldValue.arrayUnion([
          {'username': widget.username, 'answer': answer}
        ])
      });

      _fetchQuestions();
    }
  }

  void _showAnswerDialog(String id) {
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Answer the question'),
          content: TextField(
            controller: answerController,
            decoration: const InputDecoration(hintText: "Type your answer here"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _answerQuestion(id, answerController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Submit', style: TextStyle(color: Colors.teal)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Card(
        color: Colors.grey[900], // Darker background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Curved edges
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question['question'] ?? 'No question provided',
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                'Asked by ${question['askedBy'] ?? 'Unknown'}',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showAnswerDialog(question['id']),
                    icon: const Icon(Icons.reply, color: Colors.white),
                    label: const Text('Answer', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal, // Changed to teal
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15), // Curved button
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _deleteQuestion(question['id']),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (question['answers'] != null && question['answers'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: question['answers'].map<Widget>((answer) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[850]?.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              answer['answer'] ?? 'No answer provided',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'Answered by ${answer['username'] ?? 'Unknown'}',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Search questions...',
            hintStyle: const TextStyle(color: Colors.grey),
            prefixIcon: const Icon(Icons.search, color: Colors.teal),
            filled: true,
            fillColor: Colors.grey[800],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Lottie animation background (centered and reduced in size)
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              child: Lottie.network(
                'https://lottie.host/108ffc03-3596-4e07-a1b3-c6fd78c93bad/Dt61OC7mHE.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),
          // Overlay content
          filteredQuestions.isEmpty
              ? const Center(child: Text('', style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  itemCount: filteredQuestions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(filteredQuestions[index]);
                  },
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                backgroundColor: Colors.grey[900], // Darker background for the dialog
                title: const Text('Ask a Question', style: TextStyle(color: Colors.teal)),
                content: TextField(
                  controller: _questionController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: "Type your question",
                    hintStyle: TextStyle(color: Colors.grey),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.teal),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      _addQuestion();
                      Navigator.of(context).pop();
                    },
                    child: const Text('Submit', style: TextStyle(color: Colors.teal)),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
