import 'package:flutter/material.dart';

class ResultsPage extends StatelessWidget {
  final Map data;
  final Map answered;
  final int correctAnswers;

  const ResultsPage(
      {super.key, required this.data, required this.answered, required this.correctAnswers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text('Quiz Results'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(
                'You answered $correctAnswers out of ${data.length} questions correctly!',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: data.length,
                itemBuilder: (context, index) {
                  int questionNumber = index + 1;
                  String selectedOption = answered["$questionNumber"]["answered"]
                      ? data["$questionNumber"]["options"][answered["$questionNumber"]["answer"]]
                      : "Not answered";
                  String correctOption = data["$questionNumber"]["answer"];

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$questionNumber. ${data["$questionNumber"]["question"]}",
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Your answer: $selectedOption",
                            style: TextStyle(
                                color: selectedOption == correctOption ? Colors.green : Colors.red),
                          ),
                          Text(
                            "Correct answer: $correctOption",
                            style: const TextStyle(color: Colors.green),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
