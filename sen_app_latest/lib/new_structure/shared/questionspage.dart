import 'package:flutter/material.dart';
import 'package:sen_app_latest/new_structure/shared/resultspage.dart';

class QuestionsPage extends StatefulWidget {
  const QuestionsPage(
      {super.key, required this.name, required this.data, required this.ans});
  final String name;
  final Map data;
  final bool ans;
  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  int questionCount = 0;
  int currentQuestion = 1;
  bool lastQuestion = false;
  bool checkAnswer = false;
  Map answered = {
    "1": {"answered": false, "answer": 0},
    "2": {"answered": false, "answer": 0},
    "3": {"answered": false, "answer": 0},
    "4": {"answered": false, "answer": 0},
  };

  @override
  void initState() {
    super.initState();
    widget.data.forEach((key, value) {
      questionCount++;
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

  void navigateToResultsPage() {
    int correctAnswers = calcCorrect();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsPage(
          data: widget.data,
          answered: answered,
          correctAnswers: correctAnswers,
        ),
      ),
    );
  }

  Widget ansornot() {
    if (widget.ans) {
      return Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Text(
              "Answer : ${widget.data["$currentQuestion"]["answer"]}",
              style: const TextStyle(fontSize: 30),
              maxLines: null, // Allows text to expand as many lines as needed
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      );
    } else {
      return Column(
        children: [
          Padding(
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
                      answered["$currentQuestion"]["answer"] == 0
                  ? Colors.amber
                  : Colors.grey.shade200,
              onTap: () {
                // debugPrint(widget.data["a"]);
                setState(() {
                  answered["$currentQuestion"]["answered"] = true;
                  answered["$currentQuestion"]["answer"] = 0;
                });
              },
              leading: Container(
                  width: 25,
                  height: 25,
                  // alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black87),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        "A",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              title: Text(widget.data["$currentQuestion"]["options"][0]),
            ),
          ),
          Padding(
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
                      answered["$currentQuestion"]["answer"] == 1
                  ? Colors.amber
                  : Colors.grey.shade200,
              onTap: () {
                // debugPrint(widget.data["a"]);
                setState(() {
                  answered["$currentQuestion"]["answered"] = true;
                  answered["$currentQuestion"]["answer"] = 1;
                });
              },
              leading: Container(
                  width: 25,
                  height: 25,
                  // alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black87),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        "B",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              title: Text(widget.data["$currentQuestion"]["options"][1]),
            ),
          ),
          Padding(
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
                      answered["$currentQuestion"]["answer"] == 2
                  ? Colors.amber
                  : Colors.grey.shade200,
              onTap: () {
                // debugPrint(widget.data["a"]);
                setState(() {
                  answered["$currentQuestion"]["answered"] = true;
                  answered["$currentQuestion"]["answer"] = 2;
                });
              },
              leading: Container(
                  width: 25,
                  height: 25,
                  // alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black87),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        "C",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              title: Text(widget.data["$currentQuestion"]["options"][2]),
            ),
          ),
          Padding(
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
                      answered["$currentQuestion"]["answer"] == 3
                  ? Colors.amber
                  : Colors.grey.shade200,
              onTap: () {
                // debugPrint(widget.data["a"]);
                setState(() {
                  answered["$currentQuestion"]["answered"] = true;
                  answered["$currentQuestion"]["answer"] = 3;
                });
              },
              leading: Container(
                  width: 25,
                  height: 25,
                  // alignment: Alignment.center,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Colors.black87),
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Center(
                      child: Text(
                        "D",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )),
              title: Text(widget.data["$currentQuestion"]["options"][3]),
            ),
          ),
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
                  maxLines:
                      null, // Allows text to expand as many lines as needed
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ]),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Diffculty level : "),
                Text(
                  "${widget.data["$currentQuestion"]["difficultylevels"]}",
                  style: TextStyle(
                      color: widget.data["$currentQuestion"]
                                  ["difficultylevels"] ==
                              "hard"
                          ? Colors.red
                          : Colors.green),
                ),
              ],
            ),
          ),
          ansornot(),
          //
          const Expanded(child: SizedBox()),

          //
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
                      if (answered["$currentQuestion"]["answered"] ||
                          widget.ans) {
                        if (currentQuestion < questionCount) {
                          setState(() {
                            currentQuestion++;
                            if (currentQuestion == questionCount) {
                              lastQuestion = true;
                            } else {
                              lastQuestion = false;
                            }
                          });
                        } else if (lastQuestion && !widget.ans) {
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
