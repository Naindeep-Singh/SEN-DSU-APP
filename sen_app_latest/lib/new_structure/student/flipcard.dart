import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardPage extends StatelessWidget {
  final Map data;

  const FlipCardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flip Cards',
          style: TextStyle(
            color: Colors.black, // Set the title color to black
          ),
        ),
        backgroundColor: Colors.white, // Set the app bar color to white
        elevation: 0, // Remove the shadow
        iconTheme: IconThemeData(color: Colors.black), // Set the icon color to black
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // Create a key for the data using index
          String key = "${index + 1}";
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              height: 200, // Set a fixed height for all tiles
              child: FlipCard(
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data[key]?["question"] ?? "No Question",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                back: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      data[key]?["answer"] ?? "No Answer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
