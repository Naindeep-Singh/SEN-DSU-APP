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
    return Card(
      color: Colors.grey[850],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => _deleteQuestion(question['id']),
                ),
              ],
            ),
            if (question['answers'] != null && question['answers'].isNotEmpty)
              ...question['answers'].map<Widget>((answer) {
                return ListTile(
                  title: Text(answer['answer'] ?? 'No answer provided',
                      style: const TextStyle(color: Colors.grey)),
                  subtitle: Text('Answered by ${answer['username'] ?? 'Unknown'}',
                      style: TextStyle(color: Colors.grey[500])),
                );
              }).toList(),
          ],
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
                'https://lottie.host/7d2288ed-39fa-428d-afd8-878e0166f359/RPPastpfnf.json',
                fit: BoxFit.cover,
                repeat: true,
              ),
            ),
          ),
          // Overlay content
          filteredQuestions.isEmpty
              ? const Center(child: Text('', style: TextStyle(color: Colors.grey))) // add a commen foe the search bar
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
                title: const Text('Ask a Question'),
                content: TextField(
                  controller: _questionController,
                  decoration: const InputDecoration(hintText: "Type your question"),
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
