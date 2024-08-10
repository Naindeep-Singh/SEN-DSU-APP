import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentQuestions extends StatefulWidget {
  const StudentQuestions({
    super.key,
    required this.name,
    required this.username,
    required this.data,
    required this.vivaId, // Add vivaId to the widget parameters
  });

  final String name;
  final Map data;
  final String vivaId; // Store the vivaId to access the specific viva
  final String username; // Store the vivaId to access the specific viva

  @override
  State<StudentQuestions> createState() => _StudentQuestionsState();
}

class _StudentQuestionsState extends State<StudentQuestions> {
  int questionCount = 0;
  int currentQuestion = 1;
  bool lastQuestion = false;
  bool checkAnswer = false;
  Map answered = {};

  @override
  void initState() {
    super.initState();
    widget.data.forEach((key, value) {
      questionCount++;
      answered[key] = {"answered": false, "answer": 0};
    });
  }

  int calcCorrect() {
    int correctAnswers = 0;
    try {
      for (int i = 1; i <= questionCount; i++) {
        int selectedOptionIndex = answered["$i"]["answer"];
        String selectedOption =
            widget.data["$i"]["options"][selectedOptionIndex];
        if (selectedOption == widget.data["$i"]["answer"]) {
          correctAnswers++;
        }
      }
      debugPrint("Correct Answers: $correctAnswers");
      return correctAnswers;
    } catch (e) {
      debugPrint("$e");
      return correctAnswers;
    }
  }

  Future<void> updateStudentScoreInFirestore(int correctAnswers) async {
    try {
      // Reference to the specific viva document
      DocumentReference vivaDoc =
          FirebaseFirestore.instance.collection('viva').doc(widget.vivaId);

      // Update the student's score in the viva document
      await vivaDoc.set({
        'students': {
          widget.username: {
            'score': correctAnswers,
            'status': 'done',
          }
        }
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint("Error updating Firestore: $e");
    }
  }

  void navigateToResultsPage() {
    int correctAnswers = calcCorrect();
    updateStudentScoreInFirestore(
        correctAnswers); // Call this to update the score
    Navigator.pop(context);
    Navigator.pop(context);
  }

  Widget ansornot() {
    return Column(
      children: [
        ...List.generate(4, (index) {
          String optionLabel = String.fromCharCode(65 + index);
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              minLeadingWidth: 20,
              shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade600, width: 1),
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.elliptical(16, 16),
                      topRight: Radius.elliptical(16, 16),
                      bottomRight: Radius.elliptical(16, 16),
                      bottomLeft: Radius.elliptical(16, 16))),
              tileColor: answered["$currentQuestion"]["answered"] == true &&
                      answered["$currentQuestion"]["answer"] == index
                  ? Colors.amber
                  : Colors.grey.shade200,
              onTap: () {
                setState(() {
                  answered["$currentQuestion"]["answered"] = true;
                  answered["$currentQuestion"]["answer"] = index;
                });
              },
              leading: Container(
                  width: 25,
                  height: 25,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black87),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        optionLabel,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              title: Text(widget.data["$currentQuestion"]["options"][index]),
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: checkAnswer
              ? const Text(
                  'Choose an option first!',
                  style: TextStyle(color: Colors.red),
                )
              : const Text(''),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Row(
          children: [
            const Expanded(child: SizedBox()),
            Text("$currentQuestion/$questionCount")
          ],
        ),
      ),
      body: Column(
        children: [
          Row(children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: Text(
                  "$currentQuestion. ${widget.data["$currentQuestion"]["question"]}",
                  style: const TextStyle(fontSize: 30),
                  maxLines: null,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Difficulty level : "),
                Text(
                  "${widget.data["$currentQuestion"]["difficultyLevel"]}",
                  style: TextStyle(
                      color: widget.data["$currentQuestion"]
                                  ["difficultyLevel"] ==
                              "hard"
                          ? Colors.red
                          : Colors.green),
                ),
              ],
            ),
          ),
          ansornot(),
          const Expanded(child: SizedBox()),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87),
                    onPressed: () {
                      if (currentQuestion > 1) {
                        setState(() {
                          currentQuestion--;
                          lastQuestion = false;
                        });
                      }
                    },
                    child: const Text('Prev question')),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87),
                    onPressed: () {
                      setState(() {
                        checkAnswer = false;
                      });
                      if (answered["$currentQuestion"]["answered"]) {
                        if (currentQuestion < questionCount) {
                          setState(() {
                            currentQuestion++;
                            if (currentQuestion == questionCount) {
                              lastQuestion = true;
                            } else {
                              lastQuestion = false;
                            }
                          });
                        } else if (lastQuestion) {
                          navigateToResultsPage();
                        }
                      } else {
                        setState(() {
                          checkAnswer = true;
                        });
                      }
                    },
                    child: Text(lastQuestion ? 'Submit' : 'Next question')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
