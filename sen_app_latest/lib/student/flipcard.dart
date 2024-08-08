import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

class FlipCardPage extends StatelessWidget {
  final Map data;

  const FlipCardPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          // Create a key for the data using index
          String key = "${index + 1}";
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 200, // Set a fixed height for all tiles
              child: FlipCard(
                fill: Fill.fillBack,
                direction: FlipDirection.HORIZONTAL,
                side: CardSide.FRONT,
                front: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      data[key]?["question"] ?? "No Question",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                back: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      data[key]?["answer"] ?? "No Answer",
                      style: const TextStyle(color: Colors.white, fontSize: 18),
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
